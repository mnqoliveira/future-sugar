import subprocess
from io import BytesIO
import pandas as pd
from functools import reduce
import os
import numpy as np
from joblib import Parallel, delayed

def last(x):
    return(x.iloc[-1])

def extract_table(path, file_in, names):
    infile = path + '/' + file_in + '.OUT'
    result = subprocess.run(["awk", "!/[A-Za-z!-]/", infile],
            stdout=subprocess.PIPE)
    dat = pd.read_table(BytesIO(result.stdout), header=None, names=names,
            skip_blank_lines=True, sep='\s+')
    return(dat)

def sim_table(path, files, names):
    dat_list = [extract_table(path, f, n) for f, n in zip(files, names)]
    dat = reduce(lambda x, y: pd.merge(x, y, how='left',
        on=['YEAR', 'DOY', 'DAS']), dat_list)
    return(dat)

def agg_table(path, files, agg_foo, names):
    dat = sim_table(path, files, names)
    dat['EXP'] = path[11:19]
    for i in range(dat.shape[0] - 1):
        if dat.DAS[i] <= dat.DAS[i + 1]:
            dat.loc[i+1, 'YEAR'] = dat.loc[i, 'YEAR']
    dat['PERIOD'] = dat.DAP
    dat['PERIOD'] = dat.PERIOD.apply(lambda x: (min(3, int((x)/91))))
    dat = dat.groupby(['PERIOD', 'YEAR']).agg(agg_foo)
    dat.reset_index(inplace=True)
    return(dat)

def format_table(path, files, agg_foo, names):
    print('processing ' + path[11:19])
    dat = agg_table(path, files, agg_foo, names)
    dat['PERIOD'] = dat.PERIOD.apply(str)
    dat = pd.melt(dat, id_vars=['PERIOD', 'EXP', 'YEAR'])
    dat = pd.pivot_table(dat, index=['EXP', 'YEAR'], columns=['variable', 'PERIOD'])
    dat.columns = ['_'.join(x) for x in dat.columns.values]
    dat.rename(columns=lambda x: x.replace('value_', ''), inplace=True)
    dat.to_csv('dssatProc/' + path[11:19] + '.csv', header=False)
    return None

WEATHER_NAMES = ['YEAR', 'DOY', 'DAS', 'PRED', 'DAYLD', 'TWLD', 'SRAD', 'PARD',
        'CLDD', 'TMXD', 'TMND', 'TAVD', 'TDYD', 'TDWD', 'TGAD', 'TGRD', 'WDSD',
        'CO2D', 'VPDF', 'VPD']

ET_NAMES = ['YEAR', 'DOY', 'DAS', 'SRAA', 'TMAXA', 'TMINA', 'EOAA', 'EOPA',
        'EOSA1', 'ETAA', 'EPAA', 'ESAA', 'EFAA', 'EMAA', 'EOAC', 'ETAC', 'EPAC',
        'ESAC', 'EFAC', 'EMAC', 'ES1D', 'ES2D', 'ES3D', 'ES4D', 'ES5D', 'ES6D',
        'ES7D', 'ES8D', 'ES9D', 'ES10D', 'TRWUD']

SOIL_WAT_NAMES = ['YEAR', 'DOY', 'DAS', 'SWTD', 'SWXD', 'ROFC', 'DRNC', 'PREC',
    'IRC', 'IRRC', 'DTWT', 'MWTD', 'TDFD', 'TDFC', 'ROFD', 'SW1D', 'SW2D', 
    'SW3D', 'SW4D', 'SW5D', 'SW6D', 'SW7D', 'SW8D', 'SW9D', 'SW10']

PLANT_GRO_NAMES = ['YEAR', 'DOY', 'DAS', 'DAP', 'TSD', 'GSTD', 'LAIGD',
    'LGDMD', 'SMFMD', 'SMDMD', 'SUCMD', 'RDMD', 'BADMD', 'TAD', 'LSD',
    'SUID', 'LDDMD', 'LAITD', 'WSPD', 'WSGD', 'WSTD', 'SHTD', 'RDPD',
    'RL1D', 'RL2D', 'RL3D', 'RL4D', 'RL5D', 'RL6D', 'RL7D', 'RL8D', 'RL9D',
    'RL10D', 'EOSA2', 'RTLD', 'LID', 'SLAD', 'PGRD', 'BRDMD', 'LDGFD', 'TTEBC',
    'TTSPC', 'TTLEC', 'SUDMD', 'SUFMD', 'CWSI', 'RESPCF']

NAMES = [PLANT_GRO_NAMES, ET_NAMES, SOIL_WAT_NAMES, WEATHER_NAMES]

KEYS = ['DOY', 'DAS', 'DAP', 'TSD', 'GSTD', 'LAIGD', 'LGDMD', 'SMFMD', 'SMDMD',
    'SUCMD', 'RDMD', 'BADMD', 'TAD', 'LSD', 'SUID', 'LDDMD', 'LAITD', 'WSPD',
    'WSGD', 'EOSA1', 'RTLD', 'LID', 'SLAD', 'PGRD', 'BRDMD', 'LDGFD', 'TTEBC',
    'TTSPC', 'TTLEC', 'SUDMD', 'SUCMD', 'CWSI', 'RESPCF', 'SRAA', 'TMAXA',
    'TMINA', 'EOAA', 'EOPA', 'EOSA2', 'ETAA', 'EPAA', 'ESAA', 'EFAA', 'EMAA',
    'EOAC', 'ETAC', 'EPAC', 'ESAC', 'EFAC', 'EMAC', 'SWTD', 'SWXD', 'ROFC',
    'DRNC', 'PREC', 'IRRC', 'IRRC', 'DTWT', 'MWTD', 'TDFD', 'TDFC', 'ROFD',
    'PRED', 'DAYLD', 'TWLD', 'SRAD', 'PARD', 'CLDD', 'TMXD', 'TMND', 'TAVD',
    'TDYD', 'TDWD', 'TGAD', 'TGRD', 'WDSD', 'EXP']

FUN = [last, last, last, last, np.mean, np.mean, np.mean, last, last, last,
    last, last, np.mean, last, last, last, np.mean, np.mean, np.mean, np.mean,
    last, last, np.mean, np.mean, np.mean, np.mean, last, last, last, last,
    last, np.mean, np.mean, np.sum, np.mean, np.mean, np.sum, np.sum, np.sum,
    np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum,
    np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum,
    last, np.sum, np.sum, np.sum, np.sum, np.sum, np.mean, np.mean, np.sum,
    np.sum, np.mean, np.mean, np.mean, np.mean, np.mean, np.mean, np.mean,
    np.mean, np.mean, last]

AGG_FOO = dict(zip(KEYS, FUN))
for key in KEYS:
    if key.endswith('C'):
        AGG_FOO[key] = last
AGG_FOO['SUFMD'] = last
AGG_FOO['SHTD'] = last
AGG_FOO['RDMD'] = last
AGG_FOO['RDPD'] = last

if __name__ == '__main__':
    WEATHER_NAMES = ['YEAR', 'DOY', 'DAS', 'PRED', 'DAYLD', 'TWLD', 'SRAD', 'PARD',
            'CLDD', 'TMXD', 'TMND', 'TAVD', 'TDYD', 'TDWD', 'TGAD', 'TGRD', 'WDSD',
            'CO2D', 'VPDF', 'VPD']
    
    ET_NAMES = ['YEAR', 'DOY', 'DAS', 'SRAA', 'TMAXA', 'TMINA', 'EOAA', 'EOPA',
            'EOSA1', 'ETAA', 'EPAA', 'ESAA', 'EFAA', 'EMAA', 'EOAC', 'ETAC', 'EPAC',
            'ESAC', 'EFAC', 'EMAC', 'ES1D', 'ES2D', 'ES3D', 'ES4D', 'ES5D', 'ES6D',
            'ES7D', 'ES8D', 'ES9D', 'ES10D', 'TRWUD']
    
    SOIL_WAT_NAMES = ['YEAR', 'DOY', 'DAS', 'SWTD', 'SWXD', 'ROFC', 'DRNC', 'PREC',
        'IRC', 'IRRC', 'DTWT', 'MWTD', 'TDFD', 'TDFC', 'ROFD', 'SW1D', 'SW2D', 
        'SW3D', 'SW4D', 'SW5D', 'SW6D', 'SW7D', 'SW8D', 'SW9D', 'SW10']
    
    PLANT_GRO_NAMES = ['YEAR', 'DOY', 'DAS', 'DAP', 'TSD', 'GSTD', 'LAIGD',
        'LGDMD', 'SMFMD', 'SMDMD', 'SUCMD', 'RDMD', 'BADMD', 'TAD', 'LSD',
        'SUID', 'LDDMD', 'LAITD', 'WSPD', 'WSGD', 'WSTD', 'SHTD', 'RDPD',
        'RL1D', 'RL2D', 'RL3D', 'RL4D', 'RL5D', 'RL6D', 'RL7D', 'RL8D', 'RL9D',
        'RL10D', 'EOSA2', 'RTLD', 'LID', 'SLAD', 'PGRD', 'BRDMD', 'LDGFD', 'TTEBC',
        'TTSPC', 'TTLEC', 'SUDMD', 'SUFMD', 'CWSI', 'RESPCF']
    
    NAMES = [PLANT_GRO_NAMES, ET_NAMES, SOIL_WAT_NAMES, WEATHER_NAMES]
    
    KEYS = ['DOY', 'DAS', 'DAP', 'TSD', 'GSTD', 'LAIGD', 'LGDMD', 'SMFMD', 'SMDMD',
        'SUCMD', 'RDMD', 'BADMD', 'TAD', 'LSD', 'SUID', 'LDDMD', 'LAITD', 'WSPD',
        'WSGD', 'EOSA1', 'RTLD', 'LID', 'SLAD', 'PGRD', 'BRDMD', 'LDGFD', 'TTEBC',
        'TTSPC', 'TTLEC', 'SUDMD', 'SUCMD', 'CWSI', 'RESPCF', 'SRAA', 'TMAXA',
        'TMINA', 'EOAA', 'EOPA', 'EOSA2', 'ETAA', 'EPAA', 'ESAA', 'EFAA', 'EMAA',
        'EOAC', 'ETAC', 'EPAC', 'ESAC', 'EFAC', 'EMAC', 'SWTD', 'SWXD', 'ROFC',
        'DRNC', 'PREC', 'IRRC', 'IRRC', 'DTWT', 'MWTD', 'TDFD', 'TDFC', 'ROFD',
        'PRED', 'DAYLD', 'TWLD', 'SRAD', 'PARD', 'CLDD', 'TMXD', 'TMND', 'TAVD',
        'TDYD', 'TDWD', 'TGAD', 'TGRD', 'WDSD', 'EXP']
    
    FUN = [last, last, last, last, np.mean, np.mean, np.mean, last, last, last,
        last, last, np.mean, last, last, last, np.mean, np.mean, np.mean, np.mean,
        last, last, np.mean, np.mean, np.mean, np.mean, last, last, last, last,
        last, np.mean, np.mean, np.sum, np.mean, np.mean, np.sum, np.sum, np.sum,
        np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum,
        np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum,
        last, np.sum, np.sum, np.sum, np.sum, np.sum, np.mean, np.mean, np.sum,
        np.sum, np.mean, np.mean, np.mean, np.mean, np.mean, np.mean, np.mean,
        np.mean, np.mean, last]
    
    AGG_FOO = dict(zip(KEYS, FUN))
    for key in KEYS:
        if key.endswith('C'):
            AGG_FOO[key] = last
    AGG_FOO['SUFMD'] = last
    AGG_FOO['SHTD'] = last
    AGG_FOO['RDMD'] = last
    AGG_FOO['RDPD'] = last

    SIM_FILES = ['PlantGro', 'ET', 'SoilWat', 'Weather']
    targets = ['./dssatOut/' + x for x in os.listdir('./dssatOut')]

    def saver(target):
        return format_table(target, SIM_FILES, AGG_FOO, NAMES)

    Parallel(n_jobs=4)(delayed(saver)(target) for target in targets)

#    for targ in targets:
#        print('processing ' + targ)
#        dat = format_table('dssatOut/' + targ +'/', SIM_FILES, AGG_FOO, NAMES)
#        with open('dssatProc.csv', 'a') as f:
#            dat.to_csv(f, header=False)


