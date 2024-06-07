from re import L
import shutil
import yaml
import docker
import os
import argparse
import logging
import sys


logging.basicConfig(
    stream=sys.stdout, level=logging.INFO,
    format='%(asctime)s %(name)s - %(levelname)s - %(message)s')


## parset arguments and settings from settings.yaml and command line
def parse_args_and_settings(settings_file='settings.yaml'):

    # read settings from config file
    with open(settings_file) as file:
        settings = yaml.load(file, Loader=yaml.FullLoader)

    # parse command-line args
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument(
        '-v', '--verbose', action='store_true', help='print docker stdout')
    parser.add_argument(
        '-p', '--pull_latest', action='store_true',
        help='pull latest docker images before running')
    args = parser.parse_args()

    # override .yaml settings with command-line values if command-line
    # values are not False/None
    if args.verbose:
        settings.update({'docker_stdout': args.verbose})
    if args.pull_latest:
        settings.update({'pull_latest': args.pull_latest})

    return settings


## util: format print
def formatted_print(string, width=50, fill_char='#'):
    print('\n')
    if len(string) + 2 > width:
        width = len(string) + 4
    string = string.upper()
    print(fill_char * width)
    print('{:#^{width}}'.format(' ' + string + ' ', width=width))
    print(fill_char * width, '\n')


## model volume mount defintion, equivalent to 
## docker run -v host_inputdir:indocker_inputdir 
def get_ldvemis_docker_vols(settings):
    host_inputdir        = os.path.abspath(settings['host_inputdir'])
    host_outputdir       = os.path.abspath(settings['host_outputdir'])
    indocker_inputdir   = os.path.abspath(settings['indocker_inputdir'])
    indocker_outputdir  = os.path.abspath(settings['indocker_outputdir'])
    ldvemis_docker_vols = {
        host_inputdir: {                    ## source location, aka "local"  
            'bind': indocker_inputdir,      ## destination loc, aka "remote", "client"
            'mode': 'rw'},
        host_outputdir: {
            'bind': indocker_outputdir,
            'mode': 'rw'} }
    return ldvemis_docker_vols



## format container command
def get_ldvemis_cmd(settings):
    input_fname = settings['input_fname']
    output_fname = settings['output_fname']
    emis_inputfname_btw = settings['emis_inputfname_btw']
    emis_inputfname_nbtw = settings['emis_inputfname_nbtw']
    nbtw_adj_factor_fname = settings['nbtw_adj_factor_fname']
    nbtw_adj_factor_year = settings['nbtw_adj_factor_year']
    btw_pm25_increment = settings['btw_pm25_increment']
    emis_category = settings['emis_category']
    basedir = settings.get('basedir','/')
    codedir = settings.get('codedir','/')
    formattable_command = settings['formattable_command']
    ldvemis_cmd = formattable_command.format(input_fname, output_fname, emis_inputfname_btw, emis_inputfname_nbtw, nbtw_adj_factor_fname, nbtw_adj_factor_year, btw_pm25_increment, emis_category, basedir, codedir)
    return ldvemis_cmd


## pull docker client
def initialize_docker_client(settings):
    image_name = settings['docker_image']
    pull_latest = settings.get('pull_latest', False)
    client = docker.from_env()

    if pull_latest:
        print('Pulling latest image for {0}'.format(image_name))
        client.images.pull(image_name)

    return client 


## main function
def run_model(settings, client):

    # 1. PARSE SETTINGS
    input_fname = settings['input_fname']
    output_fname = settings['output_fname']
    nbtw_adj_factor_year = settings['nbtw_adj_factor_year']
    image_name = settings['docker_image']
    ldvemis_docker_vols = get_ldvemis_docker_vols(settings)
    ldvemis_cmd = get_ldvemis_cmd(settings)
    docker_stdout = settings.get('docker_stdout', False)


    # 2. RUN LDVEMIS via docker container client
    print_str = (
        "Simulating LDVEMIS with input {0} "
        "output {1}, for year {2}".format(
            input_fname, output_fname, nbtw_adj_factor_year))
    formatted_print(print_str)
    ldvemis = client.containers.run(
        image_name,
        volumes=ldvemis_docker_vols,
        command=ldvemis_cmd,
        stdout=docker_stdout,
        stderr=True,
        detach=True)
    for log in ldvemis.logs(
            stream=True, stderr=True, stdout=docker_stdout):
        print(log)


    # 3. CLEAN UP
    ldvemis.remove()
    logger.info('LDVEMIS Done!')

    return




## main script
if __name__ == '__main__':

    logger = logging.getLogger(__name__)

    # load args and settings
    settings = parse_args_and_settings()

    # start docker client
    client = initialize_docker_client(settings)

    # perform the main run
    run_model(settings, client)

    # print when finished
    logger.info("Finished")
