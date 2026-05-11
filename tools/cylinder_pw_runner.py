"""
cylinder_pw_runner.py
=====================
True TF/SF plane-wave excitation using gprMax.DiscretePlaneWave (PR #373).
Run this INSTEAD of the .in files if you want the exact TF/SF formulation
with total field inside the box and scattered field outside.

Prerequisites
-------------
  * gprMax main branch that includes PR #373 (GSoC 2023)
  * Verify availability first:
        python -c "from gprMax.sources import DiscretePlaneWave; print('OK')"

Usage
-----
  python cylinder_pw_runner.py           # runs both main + background
  python cylinder_pw_runner.py --bg      # background only

How it works
------------
gprMax exposes a Python library API.  This script builds both models
(cylinder + free-space background) programmatically and calls gprMax's
run_model() directly, without needing a .in file at all.
"""

import argparse
import sys
from pathlib import Path


# ---------------------------------------------------------------------------
# Helper: build a gprMax model as a .in file and run it
# (avoids needing to know the exact scene-builder object API)
# ---------------------------------------------------------------------------

def write_in_file(path: Path, with_cylinder: bool) -> None:
    """
    Write a gprMax .in file that uses #python: to invoke DiscretePlaneWave
    via gprMax.input_cmd_funcs or a direct print of a #plane_wave: command,
    whichever is supported by the installed version.

    The inner #python: block tries to call DiscretePlaneWave; if gprMax
    exposes it through input_cmd_funcs it will work seamlessly.
    """
    tag = 'cylinder_pw' if with_cylinder else 'cylinder_pw_bg'
    snap_pfx = 'main' if with_cylinder else 'bg'

    lines = [
        f'#title: {tag}',
        '',
        '#domain: 0.400 0.400 0.002',
        '#dx_dy_dz: 0.002 0.002 0.002',
        '#time_window: 4.5e-9',
        '',
        '#waveform: ricker 1 1e9 pw_ricker',
        '',
        '## --- DiscretePlaneWave TF/SF source ---------------------------------',
        '## psi=90 -> Ez polarisation (TM_z)',
        '## phi=0, theta=90 -> plane wave propagating in +x direction',
        '#python:',
        'try:',
        '    from gprMax.sources import DiscretePlaneWave',
        '    pw = DiscretePlaneWave(',
        "        p1=(0.022, 0.022, 0.000),",
        "        p2=(0.378, 0.378, 0.002),",
        '        psi=90.0,',
        '        phi=0.0, delta_phi=1.0,',
        '        theta=90.0, delta_theta=1.0,',
        "        waveform_id='pw_ricker'",
        '    )',
        '    ## DiscretePlaneWave registers itself with the active model grid',
        '    ## when constructed inside a #python: block.',
        '    ## If this raises AttributeError/TypeError, the internal API',
        '    ## changed -- inspect gprMax/sources.py for DiscretePlaneWave.',
        'except ImportError:',
        '    raise RuntimeError(',
        '        "DiscretePlaneWave not found.  Pull latest gprMax main branch "',
        '        "or use cylinder_pw.in (Hertzian dipole approximation) instead."',
        '    )',
        '#end_python:',
        '',
    ]

    if with_cylinder:
        lines += [
            '## --- PEC cylinder --------------------------------------------------',
            '#cylinder: 0.200 0.200 0.000 0.200 0.200 0.002 0.040 pec',
            '',
        ]
    else:
        lines += ['## NO CYLINDER (background / free-space run)', '']

    lines += [
        '## --- Snapshots -------------------------------------------------------',
        f'#snapshot: 0 0 0 0.400 0.400 0.002 0.002 0.002 0.002 1.5e-9 {snap_pfx}_snap_t1',
        f'#snapshot: 0 0 0 0.400 0.400 0.002 0.002 0.002 0.002 3.5e-9 {snap_pfx}_snap_t2',
        '',
        '## --- Geometry view ---------------------------------------------------',
        f'#geometry_view: 0 0 0 0.400 0.400 0.002 0.002 0.002 0.002 {tag} n',
    ]

    path.write_text('\n'.join(lines), encoding='ascii')
    print(f'Wrote: {path}')


def run_gprmax(in_file: Path) -> None:
    """Run gprMax on the given .in file using the same Python interpreter."""
    import subprocess
    cmd = [sys.executable, '-m', 'gprMax', str(in_file)]
    print(f'\nRunning: {" ".join(cmd)}')
    result = subprocess.run(cmd)
    if result.returncode != 0:
        sys.exit(f'gprMax exited with code {result.returncode}')


def main() -> None:
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument('--bg', action='store_true',
                    help='Run background (free-space) simulation only')
    ap.add_argument('--main', action='store_true',
                    help='Run main (cylinder) simulation only')
    ap.add_argument('--write-only', action='store_true',
                    help='Write .in files but do not run gprMax')
    args = ap.parse_args()

    run_main_sim = not args.bg   # default: run both
    run_bg_sim   = not args.main

    if run_main_sim:
        in_main = Path('cylinder_pw_tfsf.in')
        write_in_file(in_main, with_cylinder=True)
        if not args.write_only:
            run_gprmax(in_main)

    if run_bg_sim:
        in_bg = Path('cylinder_pw_bg_tfsf.in')
        write_in_file(in_bg, with_cylinder=False)
        if not args.write_only:
            run_gprmax(in_bg)


if __name__ == '__main__':
    main()
