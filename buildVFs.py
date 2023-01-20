#!/usr/bin/env python3

'''
Build script for Variable Fonts
'''

from pathlib import Path
import argparse
import subprocess
import shutil

FAMILY_NAME = 'SourceCodeVF'
ROOT_DIR = Path(__file__).parent


def get_args():
    parser = argparse.ArgumentParser(
        description=(__doc__))

    parser.add_argument(
        '-v', '--verbose',
        action='store_true',
        default=False,
        help='verbose output')

    parser.add_argument(
        '--hinted',
        action='store_true',
        default=False,
        help='hint VFs')

    parser.add_argument(
        '-d', '--debug',
        action='store_true',
        default=False,
        help='do not delete temporary files')

    return parser.parse_args()


def remove_source_otfs(slope=None):
    # deletes source otf files
    if slope:
        source_directory = ROOT_DIR.joinpath(
            f'{slope}', 'Masters')
    else:
        source_directory = ROOT_DIR

    for otf_to_delete in source_directory.rglob("master_*/*.otf"):
        subprocess.call(['rm', otf_to_delete])


def build_vf(args, slope=None):
    # default mode is being quiet
    STDOUT = subprocess.DEVNULL
    STDERR = subprocess.DEVNULL

    if any([args.verbose, args.debug]):
        # verbose output
        STDOUT = None
        STDERR = None

    if slope:
        target_dir = ROOT_DIR.joinpath(f'{slope}')
        vf_output_name = ROOT_DIR.joinpath(
            target_dir, f'{FAMILY_NAME}-{slope}')
    else:
        target_dir = ROOT_DIR
        vf_output_name = ROOT_DIR.joinpath(
            target_dir, f'{FAMILY_NAME}')

    output_otf = vf_output_name.with_suffix('.otf')
    output_ttf = vf_output_name.with_suffix('.ttf')
    designspace_file = vf_output_name.with_suffix('.designspace')
    hinting_data_file = target_dir.joinpath('vf_hinting_metadata.plist')

    # build master OTFs
    subprocess.call(
        # --mkot to set makeotf options:
        # gs to omit glyphs not in the GOADB
        # osv 4 to write os/2 table v4
        ['buildmasterotfs', '--mkot', '-gs,-osv,4', '-d', designspace_file],
        stdout=STDOUT,
        stderr=STDERR
    )

    if args.hinted:
        # split combined private dicts into FDArrays
        subprocess.call(
            ['splitpsdicts', '-m', hinting_data_file, '-d', designspace_file],
            stdout=STDOUT,
            stderr=STDERR
        )

    # merge OTFs into CFF2
    subprocess.call(
        # -k is for using 'post' table format 2
        ['buildcff2vf', '-k', '--omit-mac-names', '-d', designspace_file],
        stdout=STDOUT,
        stderr=STDERR
    )

    if args.hinted:
        # hint the file
        subprocess.call(
            ['psautohint', '--no-flex', output_otf],
            stdout=STDOUT,
            stderr=STDERR
        )

    if not args.hinted:
        # at the moment, we don’t subroutinize the hinted fonts.
        # extract and subroutinize the CFF2 table
        subprocess.call(
            ['tx', '-cff2', '+S', '+b', '-std', output_otf, '/tmp/.tb_cff2'],
            stdout=STDOUT,
            stderr=STDERR
        )

        # replace CFF2 table with subroutinized version
        subprocess.call(
            ['sfntedit', '-a', 'CFF2=/tmp/.tb_cff2', output_otf],
            stdout=STDOUT,
            stderr=STDERR
        )

    # build variable TTF with fontmake.
    subprocess.call([
        'fontmake', '-m', designspace_file, '-o', 'variable',
        '--production-names', '--output-path', output_ttf,
        '--feature-writer', 'None'],
        stdout=STDOUT,
        stderr=STDERR
    )

    # use DSIG, name, OS/2, MVAR, hhea, post, and STAT tables from OTFs
    tables_from_otf = (
        'DSIG=/tmp/.tb_DSIG,name=/tmp/.tb_name,OS/2=/tmp/.tb_os2,'
        'MVAR=/tmp/.tb_MVAR,hhea=/tmp/.tb_hhea,post=/tmp/.tb_post,'
        'STAT=/tmp/.tb_STAT,fvar=/tmp/.tb_fvar')

    subprocess.call([
        'sfntedit', '-x', tables_from_otf, output_otf])
    subprocess.call([
        'sfntedit', '-a', tables_from_otf, output_ttf])

    # use cmap, GDEF, GPOS, and GSUB tables from TTFs
    tables_from_ttf = (
        'cmap=/tmp/.tb_cmap,GDEF=/tmp/.tb_GDEF,'
        'GPOS=/tmp/.tb_GPOS,GSUB=/tmp/.tb_GSUB')

    subprocess.call([
        'sfntedit', '-x', tables_from_ttf, output_ttf])
    subprocess.call([
        'sfntedit', '-a', tables_from_ttf, output_otf])

    # move font files to target directory
    if output_otf.exists():
        shutil.move(output_otf, var_dir)
    if output_ttf.exists():
        shutil.move(output_ttf, var_dir)

    # delete build artifacts
    if not args.debug:
        remove_source_otfs(slope)


if __name__ == '__main__':
    args = get_args()
    slopes = ['Roman', 'Italic']

    if args.hinted:
        output_dir_name = 'VAR_hinted'
    else:
        output_dir_name = 'VAR'

    var_dir = ROOT_DIR.joinpath('target', output_dir_name)

    # clean existing target directory
    if var_dir.exists():
        subprocess.call(['rm', '-rf', var_dir])
    # build target directory
    var_dir.mkdir(parents=True)

    for slope in slopes:
        build_vf(args, slope)
