
build_name = function(colname, period){ return(paste0(colname, '_', period)) }
build_keep = function(a,b) return(paste0(a, '_' ,b))

conv= read.csv('conversion.csv')
ah = read.csv('header-apsim.csv')
ad = read.csv('header-dssat.csv')
colnames(ah)[2] = 'EXP'

keep = expand.grid(conv$dssat, 0:3)
keepers = mapply(build_keep, keep[,1], keep[,2])
keepers = c('EXP', keepers)

for(i in 1:nrow(conv)){
  for(period in 0:3){
    apos = grep(build_name(conv$apsim[i], period), colnames(ah))
    dname = build_name(conv$dssat[i], period)
    ah[, apos] = ah[, apos]*conv$units[i]
    colnames(ah)[apos] = dname
  }
}

ah = ah[, keepers]

drop_years = c('YEAR_1', 'YEAR_2','YEAR_3')
ah = ah[, -match(drop_years, colnames(ah))]

keepers = gsub('YEAR_0', 'YEAR', keepers)
keepers = keepers[-match(drop_years, keepers)]

ad = ad[, keepers]




