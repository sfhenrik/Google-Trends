library(dplyr)

company <- 'transferwise'

competitors <- c('moneygram',
'western union',
'fairfx',
'caxton fx',
'worldfirst',
'worldremit',
'currencyfair',
'transfergo',
'tawipay',
'xoom',
'transfast',
'remitly',
'ria money transfer',
'azimo',
'moneycorp',
'ukforex',
'hifx',
'post office money',
'transferwise',
'revolut')


competitors <- c('ZhongAn',
                'oscar health', # Do distinguish from The Oscars
                'wealthfront',
                'qufenqi',
                'funding circle',
                'kreditech',
                'avant',
                'atom bank',
                'klarna',
                'our crowd',
                'lufax',
                'robinhood',
                '%2Fm%2F0by16yq', # Square
                'motif investing',
                'xero',
                'stripe',
                'collective health',
                'credit karma',
                'adyen',
                'personal capital',
                'secure key technologies ',
                'betterment',
                'kabbage',
                'lending club',
                'prosper',
                'coinbase',
                'izettle',
                'policybazaar',
                'knip',
                'affirm',
                'circleup',
                'iex ',
                'prospa',
                'etoro',
                'spotcap',
                'jimubox',
                'transferwise',
                'rong360',
                '21inc',
                'coverfox',
                'angellist')

competitors=tolower(competitors)
rank_table <- data.frame(competitors=competitors, batch = ceiling(seq(1, length(competitors),1)/4), stringsAsFactors=F)
downloadDir = '/users/erik.johansson/downloads'
res = list()
for(i in 1:max(rank_table$batch)){
  r = which(rank_table$batch == i)
  keywords = c(rank_table$competitors[r], company)
  url = URL_GT(keywords, country='GB')
  GT_dir = downloadGT(url, downloadDir)
  GT_dir = paste(downloadDir, GT_dir, sep='/')
  res[[i]] = readGT(GT_dir)
}
res.normalised = list()
for(i in 1:length(res)){
  print(i)
  res.normalised[[i]] = res[[i]]
  r <- which(res[[i]]$Keyword==company)
  res.company <- res[[i]][r,]
  keywords = unique(res[[i]]$Keyword)
  
  for(j in 1:length(keywords)){
    print(paste("j", j))
    s = which(res[[i]]$Keyword == keywords[j])
    res.normalised[[i]]$SVI[s] = res[[i]]$SVI[s] / res.company$SVI
  }
}

df <- do.call("rbind", res.normalised)

df %>% ggplot(aes(Date, SVI,color=Keyword))+geom_line()


df.max <- df[which(df$Date==max(df$Date)),]
df.max <-df.max[!duplicated(df.max[-4]),]
rank_table <- merge(rank_table, df.max[c(3,2)], by.x='competitors', by.y='Keyword') %>% unique
rank_table <- rank_table[order(rank_table$SVI, decreasing=T),]
rank_table <- rank_table[is.finite(rank_table$SVI),]
deviation <- rank_table$SVI-mean(rank_table$SVI)
top_tier <- which(deviation > sd(rank_table$SVI)/2)
bottom_tier <- which(deviation < -sqrt(sd(rank_table$SVI))/5)
rank_table$tier <- 'mid_tier'
rank_table$tier[top_tier] <- 'top_tier'
rank_table$tier[bottom_tier] <- 'bottom_tier'

top_tier_competitors <- rank_table$competitors[which(rank_table$tier == 'top_tier')]
df[which(df$Keyword %in% top_tier_competitors),] %>% filter(Date > '2015-01-01') %>% ggplot(aes(Date, SVI,color=Keyword))+geom_line()

mid_tier_competitors <- rank_table$competitors[which(rank_table$tier == 'mid_tier')]
df[which(df$Keyword %in% mid_tier_competitors),] %>% filter(Date > '2015-01-01') %>%  ggplot(aes(Date, SVI,color=Keyword))+geom_line()

bottom_tier_competitors <- rank_table$competitors[which(rank_table$tier == 'bottom_tier')]
df[which(df$Keyword %in% bottom_tier_competitors),] %>% filter(Date > '2015-01-01') %>%  ggplot(aes(Date, SVI,color=Keyword))+geom_line()

df[-which(df$Keyword %in% bottom_tier_competitors),] %>%  filter(Date > '2014-01-01') %>% ggplot(aes(Date, SVI,color=Keyword))+geom_line()

write.cb(rank_table)
