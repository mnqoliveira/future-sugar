import os
import numpy as np
import pandas as pd
from joblib import Parallel, delayed

def last(x):
    x = list(x)
    return x[-1]

names = ['CITY', 'METHOD', 'CENARIO', 'GCM', 'VAR', 'PLANT', 'SOIL', 'CO2',
        'YEAR', 'DOY', 'DAS', 'DAP', 'TSD', 'GSTD', 'LAIGD', 'LGDMD', 'SMFMD',
        'SMDMD', 'SUCMD', 'RDMD', 'BADMD', 'TAD', 'LSD', 'SUID', 'LDDMD',
        'LAITD', 'WSPD', 'WSGD', 'WSTD', 'SHTD', 'RDPD', 'RL1D', 'RL2D',
        'RL3D', 'RL4D', 'RL5D', 'RL6D', 'RL7D', 'RL8D', 'RL9D', 'RL10D',
        'EOSA', 'RTLD', 'LID', 'SLAD', 'PGRD', 'BRDMD', 'LDGFD', 'TTEBC',
        'TTSPC', 'TTLEC', 'SUDMD', 'SUFMD', 'CWSI', 'RESPCF', 'YEAR', 'DOY',
        'DAS', 'SRAA', 'TMAXA', 'TMINA', 'EOAA', 'EOPA', 'EOSA', 'ETAA', 
        'EPAA', 'ESAA', 'EFAA', 'EMAA', 'EOAC', 'ETAC', 'EPAC', 'ESAC', 
        'EFAC', 'EMAC', 'ES1D', 'ES2D', 'ES3D', 'ES4D', 'ES5D', 'ES6D', 
        'ES7D', 'ES8D', 'ES9D', 'ES10', 'YEAR', 'DOY', 'DAS', 'SWTD', 'SWXD',
        'ROFC', 'DRNC', 'PREC', 'IRC', 'IRRC', 'DTWT', 'MWTD', 'TDFD', 'TDFC',
        'ROFD', 'SW1D', 'SW2D', 'SW3D', 'SW4D', 'SW5D', 'SW6D', 'SW7D','SW8D',
        'SW9D', 'SW10', 'YEAR', 'DOY', 'DAS', 'PRED', 'DAYLD', 'TWLD', 'SRAD',
        'PARD', 'CLDD', 'TMXD', 'TMND', 'TAVD', 'TDYD', 'TDWD', 'TGAD',
        'TGRD', 'WDSD', 'CO2D']

keep = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
        20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 41, 42, 43, 44, 45, 46, 47,
        48, 49, 50, 51, 52, 53, 54, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68,
        69, 70, 71 , 72, 73, 74, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98,
        99, 113, 114,115, 116 , 117, 118, 119, 120, 121, 122, 123, 124,
        125, 126]

keys = ['CITY', 'METHOD', 'CENARIO', 'GCM', 'VAR', 'PLANT', 'SOIL', 'CO2',
        'YEAR', 'DOY', 'DAS', 'DAP', 'TSD', 'GSTD', 'LAIGD', 'LGDMD', 'SMFMD',
        'SMDMD', 'SUCMD', 'RDMD', 'BADMD', 'TAD', 'LSD', 'SUID', 'LDDMD', 
        'LAITD', 'WSPD', 'WSGD', 'EOSA', 'RTLD', 'LID', 'SLAD', 'PGRD', 
        'BRDMD', 'LDGFD', 'TTEBC', 'TTSPC', 'TTLEC', 'SUDMD', 'SUFMD', 'CWSI', 
        'RESPCF', 'SRAA', 'TMAXA', 'TMINA', 'EOAA', 'EOPA', 'EOSA', 'ETAA', 
        'EPAA', 'ESAA', 'EFAA', 'EMAA', 'EOAC', 'ETAC', 'EPAC', 'ESAC', 'EFAC', 
        'EMAC', 'SWTD', 'SWXD', 'ROFC', 'DRNC', 'PREC', 'IRC', 'IRRC', 'DTWT', 
        'MWTD', 'TDFD', 'TDFC', 'ROFD', 'PRED', 'DAYLD', 'TWLD', 'SRAD', 
        'PARD', 'CLDD', 'TMXD', 'TMND', 'TAVD', 'TDYD', 'TDWD', 'TGAD', 'TGRD',
        'WDSD']

func = [last, last, last, last, last, last, last, last, last, last, last,
        last, last, np.mean, np.mean, np.mean, last, last, last, last, last,
        np.mean, last, last, last, np.mean, np.mean, np.mean, np.mean, last,
        last, np.mean, np.mean, np.mean, np.mean, last, last, last, last, last,
        np.mean, np.mean, np.sum, np.mean, np.mean, np.sum, np.sum, np.sum,
        np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum,
        np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum, np.sum,
        last, np.sum, np.sum, np.sum, np.sum, np.sum, np.mean, np.mean, np.sum,
        np.sum, np.mean, np.mean, np.mean, np.mean, np.mean, np.mean, np.mean,
        np.mean, np.mean]

foo_dict = dict(zip(keys, func))
keys90 = [x + '90' for x in keys[12:]]
foo_dict90 = dict(zip(keys90, func[12:]))
keys180 = [x + '180' for x in keys[12:]]
foo_dict180= dict(zip(keys180, func[12:]))
keys270 = [x + '270' for x in keys[12:]]
foo_dict270= dict(zip(keys270, func[12:]))

aggdict = dict()
for d in [foo_dict, foo_dict90, foo_dict180, foo_dict270]:
    aggdict.update(d)


names = [names[i] for i in keep]
types = [str]*8 + [np.float]*80
dictypes = dict(zip(names, types))

pathin = 'JACA1113'

def agg_file(path, names, dictypes, aggdict): 
    pathin = path + '/' + path + '.dat'
    print('===================================================================')
    print('Reading' + pathin)
    dat = pd.read_csv(pathin, sep=' ', header=None, usecols = keep,
            names=names, dtype=dictypes)
    dat90 = dat.iloc[:, 12:].shift(90)
    dat90.rename(columns=lambda x: x+'90', inplace=True)
    dat180 = dat.iloc[:, 12:].shift(180)
    dat180.rename(columns=lambda x: x+'180', inplace=True)
    dat270 = dat.iloc[:, 12:].shift(270)
    dat270.rename(columns=lambda x: x+'270', inplace=True)
    columns = list(dat.columns) + list(dat90.columns) + \
              list(dat180.columns) + list(dat270.columns)
    dat = pd.concat([dat, dat90, dat180, dat270], axis=1, ignore_index=True)
    print('Time delta variables created')
    dat.columns = columns
    dat.dropna(inplace=True)
    pathaux = path + '/Summary.OUT'
    aux = pd.read_csv(pathaux, sep='\s+', skiprows=4,
                      header=None, usecols=[0, 16], names=['id', 'hdat'])
    aux['hdat'] = aux['hdat'].astype(str)
    dat_id = [x+y for x,y in zip(dat['YEAR'].astype(int).astype(str),
    dat['DOY'].astype(int).astype(str))]
    iddate = [any(did == aux_did for aux_did in aux['hdat'].astype(str)) 
              for did in dat_id]
    idharv = [x > 365 for x in dat['DAP']]
    ids = [x & y for x,y in zip(iddate, idharv)]
    linesend = [i for i,x in enumerate(ids) if x]
    linesbegin = [x-89 for x in linesend]
    dfs = list()
    print('Aggregating data')
    for lbeg, lend, rep in zip(linesbegin, linesend, aux['id']):
        temp = dat.iloc[lbeg:(lend + 1),:].copy()
        temp['rep'] = rep
        temp = temp.groupby('rep').agg(aggdict)
        dfs.append(temp.values[0])
    df = pd.DataFrame(dfs, columns=aggdict.keys())
    order = keys + keys90 + keys180 + keys270
    df = df.loc[:, order]
    pathout = path + '/' + path + '.csv'
    print('Printing' + pathout + '\n')
    df.to_csv(pathout, header=False, index=False)
    return None

targets = [name for name in os.listdir('./') if 
           os.path.isdir(os.path.join('./', name))]
print(targets)

Parallel(n_jobs=2)(delayed(agg_file)(target, names, dictypes, aggdict)
        for target in targets)

# for target in targets:
    # agg_file(target, names, dictypes, aggdict)


