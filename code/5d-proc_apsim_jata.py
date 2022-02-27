import pandas as pd
import os
import numpy as np

def last(x):
    return(x.iloc[-1])

def get_info(filename):
    date_code = filename[5]
    year = filename[9:13]
    exp = filename[:8]
    return int(date_code), int(year), exp

def proc_apsim(path, filename, agg_foo, date_dict, error_flag):
    dat = pd.read_table(path + filename, header=2, skiprows=[3],
            sep='\s+', error_bad_lines=error_flag, na_values = '?')
    date_code, year, exp = get_info(filename)
    n_lead = date_dict[date_code]  - 1
    dat['period'] = dat.simulation_days - n_lead
    dat = dat.loc[dat.period.isin(list(range(1,365))),: ]
    dat['period'] = dat.period.apply(lambda x: str(min(3, int(x/91))))
    dat = dat.groupby('period').agg(agg_foo)
    dat.reset_index(inplace=True)
    dat['exp'] = exp
    dat = pd.melt(dat, id_vars=['exp', 'period'])
    dat = pd.pivot_table(dat, index='exp', columns=['variable', 'period'])
    dat.columns = ['_'.join(x) for x in dat.columns.values]
    dat.reset_index(inplace=True)
    dat.rename(columns=lambda x: x.replace('value_', ''), inplace=True)
    return dat


# segundo numero é data do init
# 1: 134
# 2: 226 
# 3: 318
# somar 1 na data do init, subtrair isso de simulation_days e filtrar


if __name__ == '__main__':
    AGG_FOO = {'day_of_year': last,
            'simulation_days': last,
            'daysaftersowing': last,
            'year': last,
            'biomass': last,
            'canefw': last,
            'cane_wt': last,
            'sucrose_wt': last,
            'ccs': last,
            'scmst': last,
            'scmstf': last,
            'cabbage_wt': last,
            'green_biomass': last,
            'esw': np.nanmean,
            'lai': last,
            'nfact_photo': np.nanmean,
            'root_depth': last,
            'CO2': last,
            'day_length': np.nanmean,
            'MaxT': np.nanmean,
            'MinT': np.nanmean,
            'Radn': np.nansum,
            'Rain': np.nansum,
            'es': np.nansum,
            'eo': np.nansum,
            'biomass.1': last,
            'cane_dmf': last,
            'cover_green': last,
            'cover_tot': last,
            'dlt_dm': np.nanmean,
            'dlt_dm_green': np.nanmean,
            'dm_dead': last,
            'ep': np.nansum,
            'height': np.nanmean,
            'lai_sum': last,
            'lai2': last,
            'leaf_wt2': last,
            'leafgreenwt': np.nansum,
            'plants': np.nanmean,
            'radn_int': np.nansum,
            'rootgreenwt': last,
            'senescedn': last,
            'senescedwt': last,
            'sstem_wt': last,
            'slai': last,
            'stage_code': last,
            'sw_demand': np.nansum,
            'sw_demand_te': np.nansum,
            'swdef_expan': np.nansum,
            'swdef_pheno': np.nansum,
            'swdef_photo': np.nansum,
    'swdef_stalk': np.nansum,
               'tla': last,
               'tlai': last,
               'irrigation': np.nansum}
    BASE = '/run/media/boccaff/Seagate Backup Plus Drive/Monique/apsim-out/'
    #SUBDIRS = ['jata/', 'pira/', 'resi/']
    subdir = 'jata/'
    DATA_DIC = {1:135, 2:227, 3:319}
    targets = [x for x in  os.listdir(BASE + subdir)if x.endswith('.out')]
    try:
        done = pd.read_csv('apsimProc_jata.csv', usecols=[1], names=['file'])
        done = set(done.file.values)
        targets = [x for x in targets if x[:7] not in done]
    except FileNotFoundError :
        print('starting processing of targets')
    for targ in targets:
        print('processing ' + targ)
        try:
            dat = proc_apsim(BASE + subdir, targ, AGG_FOO, DATA_DIC, True)
            with open('apsimProc_jata.csv', 'a') as f:
                dat.to_csv(f, header=False)
        except pd.errors.ParserError:
            dat = proc_apsim(BASE + subdir, targ, AGG_FOO, DATA_DIC, False)
            with open('apsimProc_jata.csv', 'a') as f:
                dat.to_csv(f, header=False)
            with open('bad_lines_jata.csv', 'a') as f:
                f.write(targ + '\n')
        except UnicodeDecodeError:
            with open('corrupted_jata.csv', 'a') as f:
                f.write(targ + '\n')


