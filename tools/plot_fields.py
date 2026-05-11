"""
plot_fields.py
==============
Read gprMax VTK snapshot files (.vti) from both the main (cylinder) and
background (free-space) runs, then produce a 2-row × 3-column figure:

    Row 0  t = 1.5 ns : Total | Incident | Scattered  Ez
    Row 1  t = 3.5 ns : Total | Incident | Scattered  Ez

TF/SF interpretation:
  Inside  TF/SF box  →  total field  (E_total)
  Outside TF/SF box  →  scattered field only
  E_scattered everywhere = E_total (main run) − E_incident (background run)

Dependencies:
    pip install pyvista matplotlib numpy

Usage:
    python plot_fields.py [--snapdir DIR]

Snapshot files expected (must match #snapshot identifiers in the .in files):
    main_snap_t1.vti  main_snap_t2.vti   (from cylinder_pw.in)
    bg_snap_t1.vti    bg_snap_t2.vti     (from cylinder_pw_bg.in)

gprMax places snapshot .vti files in the same directory as the .out file,
which defaults to the directory containing the .in file.  Adjust SNAP_DIR
below or pass --snapdir on the command line if they live elsewhere.
"""

import argparse
from pathlib import Path

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
import matplotlib.ticker as ticker

try:
    import pyvista as pv
except ImportError as exc:
    raise SystemExit(
        "pyvista is required.  Install with:  pip install pyvista"
    ) from exc


# ── Model parameters — must match the .in files ──────────────────────────────
DX = DY = 0.002          # cell size (m)
NX, NY = 200, 200         # number of cells in x and y
NZ = 1                    # 2-D model: 1 cell thick in z

# TF/SF box extents (m), matching p1/p2 in DiscretePlaneWave
TFSF = dict(x1=0.022, y1=0.022, x2=0.378, y2=0.378)

# PEC cylinder
CYL = dict(cx=0.200, cy=0.200, r=0.040)

# PML thickness
PML_CELLS = 10
PML_M = PML_CELLS * DX

# Snapshot times for axis labels
SNAP_LABELS = {0: 't = 1.5 ns', 1: 't = 3.5 ns'}

# Snapshot filename stems (no extension) — adjust if gprMax prefixes them
SNAP_MAIN = ['main_snap_t1', 'main_snap_t2']
SNAP_BG   = ['bg_snap_t1',   'bg_snap_t2']


# ── VTK I/O ──────────────────────────────────────────────────────────────────

def read_Ez(vti_path: Path) -> np.ndarray:
    """
    Load Ez field from a gprMax VTK ImageData snapshot.

    Returns
    -------
    Ez : ndarray, shape (NY, NX)
        Ez in V/m, arranged for imshow(origin='lower').

    Notes
    -----
    gprMax stores field components as cell-centred data in the VTK file.
    Cell data is ordered x-fastest (Fortran order) with the grid layout
    matching the FDTD Yee mesh.  For a 2-D model NZ=1 the z-slice is
    trivially squeezed out.
    """
    if not vti_path.exists():
        raise FileNotFoundError(
            f"Snapshot not found: {vti_path}\n"
            "Check SNAP_DIR and that both gprMax simulations have been run."
        )

    grid = pv.read(str(vti_path))

    # Find the Ez array — gprMax names it 'Ez' in the cell data
    cell_keys = list(grid.cell_data.keys())
    ez_key = next((k for k in cell_keys if k.lower() == 'ez'), None)
    if ez_key is None:
        raise KeyError(
            f"No 'Ez' field found in {vti_path.name}.\n"
            f"Available fields: {cell_keys}"
        )

    # Reshape: VTK cell data is stored x-fastest (Fortran / column-major)
    Ez_xyz = np.array(grid.cell_data[ez_key]).reshape(
        (NX, NY, NZ), order='F'
    )                             # (NX, NY, NZ)
    Ez_yx = Ez_xyz[:, :, 0].T    # (NY, NX)  — imshow row=y, col=x
    return Ez_yx


# ── Plot helpers ──────────────────────────────────────────────────────────────

def _annotate(ax: plt.Axes) -> None:
    """Overlay TF/SF box, PML boundary, and PEC cylinder on an axes."""
    extent_m = [0, NX * DX, 0, NY * DY]

    # PML inner boundary
    ax.add_patch(patches.Rectangle(
        (PML_M, PML_M),
        extent_m[1] - 2 * PML_M, extent_m[3] - 2 * PML_M,
        lw=0.7, edgecolor='0.5', facecolor='none', ls=':',
        label='PML boundary'
    ))
    # TF/SF box
    ax.add_patch(patches.Rectangle(
        (TFSF['x1'], TFSF['y1']),
        TFSF['x2'] - TFSF['x1'], TFSF['y2'] - TFSF['y1'],
        lw=1.0, edgecolor='k', facecolor='none', ls='--',
        label='TF/SF box'
    ))
    # PEC cylinder
    ax.add_patch(patches.Circle(
        (CYL['cx'], CYL['cy']), CYL['r'],
        lw=1.5, edgecolor='w', facecolor='none',
        label='PEC cylinder'
    ))

    # Incident arrow
    ax.annotate('', xy=(0.08, 0.200), xytext=(0.018, 0.200),
                xycoords='data',
                arrowprops=dict(arrowstyle='->', color='k', lw=1.2))


def _imshow(ax: plt.Axes, Ez: np.ndarray, title: str,
            vmax: float) -> plt.cm.ScalarMappable:
    extent = [0, NX * DX, 0, NY * DY]
    im = ax.imshow(
        Ez, origin='lower', extent=extent,
        cmap='RdBu_r', vmin=-vmax, vmax=vmax,
        interpolation='bilinear', aspect='equal'
    )
    _annotate(ax)
    ax.set_title(title, fontsize=10)
    ax.set_xlabel('x (m)')
    ax.set_ylabel('y (m)')
    ax.xaxis.set_major_formatter(ticker.FormatStrFormatter('%.2f'))
    ax.yaxis.set_major_formatter(ticker.FormatStrFormatter('%.2f'))
    return im


def _add_colorbar(fig: plt.Figure, ax: plt.Axes,
                  im: plt.cm.ScalarMappable) -> None:
    cbar = fig.colorbar(im, ax=ax, fraction=0.046, pad=0.04)
    cbar.set_label('E$_z$ (V/m)', fontsize=8)
    cbar.ax.tick_params(labelsize=7)


# ── Main ─────────────────────────────────────────────────────────────────────

def main(snap_dir: Path) -> None:
    n_times = len(SNAP_MAIN)

    fig, axes = plt.subplots(
        n_times, 3,
        figsize=(14, 4.8 * n_times),
        constrained_layout=True
    )
    if n_times == 1:
        axes = axes[np.newaxis, :]   # keep 2-D indexing

    fig.suptitle(
        'TM$_z$ Plane-Wave Scattering from PEC Cylinder  '
        r'($f_c = 1$ GHz,  $ka \approx 0.84$)'
        '\n'
        'Dashed box = TF/SF boundary  |  dotted = PML  |  '
        'white circle = PEC cylinder',
        fontsize=11
    )

    for row in range(n_times):
        Ez_tot  = read_Ez(snap_dir / (SNAP_MAIN[row] + '.vti'))
        Ez_inc  = read_Ez(snap_dir / (SNAP_BG[row]   + '.vti'))
        Ez_scat = Ez_tot - Ez_inc

        vmax = float(np.max(np.abs(Ez_tot))) * 0.85 or 1.0

        label = SNAP_LABELS[row]
        im0 = _imshow(axes[row, 0], Ez_tot,  f'Total field  E$_z$\n{label}', vmax)
        im1 = _imshow(axes[row, 1], Ez_inc,  f'Incident field  E$_z$\n{label}', vmax)
        im2 = _imshow(axes[row, 2], Ez_scat, f'Scattered field  E$_z$ = Total − Incident\n{label}', vmax)

        for ax, im in zip(axes[row], (im0, im1, im2)):
            _add_colorbar(fig, ax, im)

        # Label TF/SF regions on the total-field panel
        ax0 = axes[row, 0]
        ax0.text(
            TFSF['x1'] + 0.010, TFSF['y2'] - 0.015,
            'Total\nfield', fontsize=7, color='k',
            ha='left', va='top',
            bbox=dict(boxstyle='round,pad=0.2', fc='w', alpha=0.6, ec='none')
        )
        ax0.text(
            0.005, NY * DY - 0.010,
            'Scattered\nfield', fontsize=7, color='0.3',
            ha='left', va='top',
            bbox=dict(boxstyle='round,pad=0.2', fc='w', alpha=0.6, ec='none')
        )

    # Shared legend from first panel
    handles, labels_ = axes[0, 0].get_legend_handles_labels()
    # deduplicate
    seen = {}
    for h, l in zip(handles, labels_):
        seen.setdefault(l, h)
    fig.legend(seen.values(), seen.keys(),
               loc='lower center', ncol=3, frameon=True,
               bbox_to_anchor=(0.5, -0.01), fontsize=9)

    out_png = Path('cylinder_pw_fields.png')
    fig.savefig(out_png, dpi=150, bbox_inches='tight')
    plt.show()
    print(f"Saved → {out_png.resolve()}")


if __name__ == '__main__':
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--snapdir', type=Path, default=Path('.'),
                    help='Directory containing the .vti snapshot files '
                         '(default: current directory)')
    args = ap.parse_args()
    main(args.snapdir)
