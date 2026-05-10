"""
Defines a colection of wire amtemmas for use in gprMax
"""

# from gprMax.exceptions import CmdInputError
from gprMax.input_cmd_funcs import edge, voltage_source, rx, Coordinate

def half_wavelength_dipole(x,y,z, frequency=1e9, resolution=0.002):
    """
    """
    f = frequency
    # dx = resolution
    dy = resolution
    # dz = resolution

    # Polarization
    polarisation = 'y'

    # Antenna geometry properties
    lam = 299792458/f
    len_dipole = lam/2.0

    # PEC
    edge(xs = x, ys = y - len_dipole/2, zs = z,
         xf = x, yf = y + len_dipole/2 + dy, zf = z, material = 'pec')
    # Gap
    edge(xs = x, ys = y, zs = z,
         xf = x, yf = y + dy, zf = z, material = 'free_space')
    c = Coordinate(x,y,z)

    return c


def half_wavelength_dipole_pat(x, y, z, frequency=1e9, resolution=0.002, waveform='gaussian', rotate90=False):
    """
    Inserts a half-wavelength dipole antenna for pattern validation.
    It can be used with 1 GHz length (30 cm default)
    It can be used with 2mm (default) or any spatial resolution.
    One output point is defined between the arms of the receiver.
    The dipoles are aligned with the y axis so the output is the
    y component of the electric field (x component if the antenna
    is rotated 90 degrees).

    Args:
        x, y, z (float): Coordinates of a location in the model to insert
                         the antenna. Coordinates are relative to the geometric centre of
                         the antenna in the x-y plane.
        frequency (float):
        waveform (string): defines a voltage source wavwform
        resolution (float): Spatial resolution for the antenna model.
        rotate90 (bool): Rotate model 90 degrees CCW in xy plane.
    """

    f = frequency
    # dx = resolution
    dy = resolution
    # dz = resolution

    # Coordinates of source excitation point in antenna
    tx = x, y, z

    # Antenna geometry properties
    lam = 299792458/f
    len_dipole = lam/2.0

    # Set origin for rotation to geometric centre of antenna in x-y plane
    # if required, and set output component for receiver
    if rotate90:
        rotate90origin = (x, y)
        output = 'Ex'
    else:
        rotate90origin = ()
        output = 'Ey'

    # PEC
    edge(xs = x, ys = y - len_dipole/2, zs = z,
         xf = x, yf = y + len_dipole/2 + dy, zf = z, material = 'pec')
    # Gap
    edge(xs = x, ys = y, zs = z,
         xf = x, yf = y + dy, zf = z, material = 'free_space')

    # Gaussian pulse
    sourceresistance = 73 # Ohms
    print(f'#waveform: {waveform} 1 {f} my_waveform')
    voltage_source('y', tx[0], tx[1], tx[2], sourceresistance, 'my_waveform',
                    rotate90origin=rotate90origin)

    rx(tx[0], tx[1], tx[2], identifier='half_wavelength_dipole',
        to_save=[output], polarisation='y', rotate90origin=rotate90origin)
