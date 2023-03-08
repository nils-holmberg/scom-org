library(tidyverse)#, lib.loc="~/lib/r-cran")
library(lme4)#, lib.loc="~/lib/r-cran")

#~ ##################################################################### 210714
#note that exclusion critera at end can be commented out
posts_get <- function(fn='csv/sa-191120.csv') {
#read data
dfm = read.table(fn, sep='\t', header=T, strip.white=TRUE, stringsAsFactors=FALSE)
#index
dfm$index = seq(length(dfm$group))
#use date bins value for rank order month
dfm$month = as.numeric(as.factor(dfm$bins))
#convert to date
dfm$date = as.Date(dfm$date)
#measures to positive, for log transform
#dfm$e_index = dfm$e_index + abs(min(dfm$e_index, na.rm=T)) + 1
#dfm$sa_val = dfm$sa_val + abs(min(dfm$sa_val, na.rm=T)) + 1
#dfm$follow = dfm$follow + abs(min(dfm$follow, na.rm=T)) + 1
#new independent measures, emotional intensity
dfm$sa_int_abs = dfm$sa_pos + abs(dfm$sa_neg)
dfm$sa_int = dfm$sa_val^2
#get variables, post word count
dfm$wc = sapply(strsplit(dfm$text, " "), length)
#relative to post word count
#dfm$sa_int_rel = dfm$sa_int / dfm$wc
#dfm$sa_frq_rel = dfm$sa_frq / dfm$wc
#engagement index relative to number of followers
#dfm$e_index_rel = dfm$e_index / dfm$follow

dfm$out = 0
if (T) {
#new 100K dataset, exclude earliest posts
dfm = dfm[ dfm$month > 30 & dfm$month <= 90 , ]
#fix glitch in 2 rows ..
dfm$out[is.na(dfm$sa_val)] = 1
#alternatively, remove these rows, same rows across sa measures
dfm = dfm[!is.na(dfm$sa_val),]
#filter orgs with more than 60 posts total, 1 post per month on average
dfm = subset(dfm, org %in% rownames(table(dfm$org)[table(dfm$org)>=60]))
#filter orgs with less than 2000 posts total
dfm = subset(dfm, org %in% rownames(table(dfm$org)[table(dfm$org)<=2000]))
#suggest outliers
dfm$out = 0
dfm$out[(rownames(dfm) %in% which(dfm$e_index %in% boxplot(dfm$e_index, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$sa_val %in% boxplot(dfm$sa_val, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$sa_int %in% boxplot(dfm$sa_int, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$sa_frq %in% boxplot(dfm$sa_frq, plot=FALSE)$out))] = 1
#dfm$out[(rownames(dfm) %in% which(dfm$emnum %in% boxplot(dfm$emnum, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$follow %in% boxplot(dfm$follow, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$wc %in% boxplot(dfm$wc, plot=FALSE)$out))] = 1
}

#export data
#write.table(dfm, "/tmp/scom/sa-cases-190605.csv", sep="\t", row.names=F)
#
return(dfm)
}

orgs_normalize <- function(dfm, colv) {
#add computed cols with NA if outlier
for (coln in colv) { 
dfm[[ paste0(coln, "_norm") ]] = NA
#normalize all variables within orgs
for (orgn in rownames(table(dfm$org))) {
dfm[[ paste0(coln, "_norm") ]][ dfm$org==orgn & dfm$out!=1 ] = normalize(dfm[[ coln ]][ dfm$org==orgn & dfm$out!=1 ])
}
#normalize all variables across orgs
#dfm[[ paste0(coln, "_norm") ]][ dfm$out!=1 ] = normalize(dfm[[ coln ]][ dfm$out!=1 ])
}
#normalize single variable across orgs
#dfm[[ "time_norm" ]][ dfm$out!=1 ] = normalize(dfm[[ "time" ]][ dfm$out!=1 ])
#
return(dfm)
}

log_transform <- function(dfm, colv) {
#add computed cols with NA if outlier
for (coln in colv) { 
print(coln)
dfm[[ paste0(coln, "_log") ]] = NA
dfm[[ paste0(coln, "_log") ]][ dfm$out!=1 ] = log(dfm[[ coln ]][ dfm$out!=1 ])
}
#
return(dfm)
}

#~ ##################################################################### 210713
pvals_simple_get <- function(m) {
#coefs
coefs <- data.frame(coef(summary(m)))
# use normal distribution to approximate p-value
coefs$p.z <- 2 * (1 - pnorm(abs(coefs$t.value)))
#round
mp = round(coefs, 3)
#rownames
mp$term = rownames(mp)
#
return(mp)
}

#~ ##################################################################### 210713
time_aggregate <- function(dfm, colv) {
#aggregate all variables in single dataframe
dfa = as.data.frame(unique(dfm$bins))
colnames(dfa)[1] = "bins"
#time
dfa$month = seq(length(dfa$bins))
#
for (coln in colv) { 
print(coln)
#handle outliers
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm[[ coln ]] %in% boxplot(dfm[[ coln ]], plot=FALSE)$out), 1, 0)
#emoji num, no outlier analysis
#dfa = cbind(dfa, aggregate(emnum_norm ~ bins, FUN=mean, data=dfm)[2])
#aggregate
dfa = cbind(dfa, aggregate(dfm[[ coln ]][dfm$sa_out!=1] ~ dfm$bins[dfm$sa_out!=1], FUN=mean)[2])
#
colnames(dfa)[ncol(dfa)] = coln
}
# select 5*12 months
#dfa = dfa[1:60,]
#new 100K dataset
#dfa = dfa[30:90,]
#
return(dfa)
}

orgs_aggregate <- function(dfm, colv) {
#aggregate all variables in single dataframe
i=T
for (coln in colv) { 
print(coln)
#bp1 <- plyr::ddply(dfm, c("org"), plyr::summarize,
#N=length(get(coln)), mean=mean(get(coln)), sd=sd(get(coln)), se=sd/sqrt(N))
bp1 = do.call(eval(parse(text="plyr::ddply")), list(dfm, c("org"), plyr::summarize, 
N=call("length", as.symbol(coln)), 
mean=call("mean", as.symbol(coln)),
sd=call("sd", as.symbol(coln))))
bp1$se=bp1$sd/sqrt(bp1$N)

if (i) {
dfa = dfp %>% count(org) %>% left_join(dfp %>% filter(out!=1) %>% count(org), by=c("org"="org"))
}

dfa = cbind(dfa, bp1[,3:5])
colnames(dfa)[(ncol(dfa)-2):(ncol(dfa))] = c(paste0(coln,"_mean"),paste0(coln,"_sd"),paste0(coln,"_se"))
i=F
}
#
return(dfa)
}

#~ ##################################################################### 210304
aggregate_get <- function(dfm) {
#aggregate all variables in single dataframe
dfa = as.data.frame(unique(dfm$bins))
colnames(dfa)[1] = "bins"
#time
dfa$month = seq(length(dfa$bins))
#engagement
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$e_index %in% boxplot(dfm$e_index, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(e_index ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#word count
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$wc %in% boxplot(dfm$wc, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(wc ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#valence
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$sa_val %in% boxplot(dfm$sa_val, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(sa_val ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#intensity
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$sa_int %in% boxplot(dfm$sa_int, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(sa_int ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#frequency
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$sa_frq %in% boxplot(dfm$sa_frq, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(sa_frq ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#emoji num, no outlier analysis
dfa = cbind(dfa, aggregate(emnum ~ bins, FUN=mean, data=dfm)[2])
# select 5*12 months
#dfa = dfa[1:60,]
#new 100K dataset
dfa = dfa[30:90,]
#
return(dfa)
}

#~ ##################################################################### 210303
column_match <- function(fb="xaa") {
#test re-import
dfe = read.table(paste0("~/get/scom-org/fb-emoji-", fb, ".csv"), sep='\t', quote="\"", header=F, strip.white=TRUE, stringsAsFactors=FALSE, blank.lines.skip=F)

colnames(dfe) = c("post_id","﻿page_name","user_name","facebook_id","likes_at_posting","created","type","likes","comments","shares","love","wow","haha","sad","angry","care","video_share_status","post_views","total_views","total_views_for_all_crossposts","video_length","url","message","link","final_link","image_text","link_text","description","sponsor_id","sponsor_name","overperforming_score","post_lang","emoji","emnum")

dfe$reactions_count = rowSums(dfe[, c("love","wow","haha","sad","angry","care")])
dfe$engagement_index = rowSums(dfe[, c("likes","comments","shares","reactions_count")])

dfe = dfe %>% select(c("post_id","message","user_name","created","post_lang","likes_at_posting","likes","comments","shares","reactions_count","engagement_index","emoji","emnum"))

colnames(dfe)[c(1,2,3,4)] = c('post_id','post_message','by','post_published_unix')
colnames(dfe)[c(7,8,9)] = c('likes_count_fb','comments_count_fb','shares_count_fb')

dfe$post_published_unix = as.numeric(as.POSIXct(dfe$post_published_unix))

#fix situation: word<tcomma>
dfe = dfe %>% mutate(post_message = gsub("<[a-z]{4,9}>", "", post_message))

#export data
write.table(dfe, paste0("csv/fb-emoji-", fb, ".csv"), sep='\t', row.names=F)
#
}


#~ ##################################################################### 210218
#emoji_to_text <- function(fp, op="/tmp/") {
emoji_to_text <- function(x) {
#fl = c("~/get/scom-org/xaa","~/get/scom-org/xab")
fp = fl[x]
#
print(paste("processing ...", fp))
fb = basename(fp)
#if (!file.exists("tmp/leaflet.R")) { print("does not exist"); }

#ore: An R Interface to the Onigmo Regular Expression Library
#install.packages("ore", lib="~/lib/r-cran")
library(ore, lib.loc="~/lib/r-cran")
emoji <- read.csv("csv/emoticon_conversion_noGraphic.csv", header=FALSE, stringsAsFactors=FALSE)
emoji_regex <- sprintf("(%s)", paste0(emoji$V2, collapse="|"))
compiled <- ore(emoji_regex)
#emoji texts !cut -f23 csv/fb-emo-norm-sample.csv | tail -n +2 > tmp/emoji-210218.txt
#text <- readLines(paste0("tmp/emoji-", fb, ".txt"), encoding="UTF-8", warn=FALSE)
text <- readLines(paste0("tmp/field-", fb, "-23.csv"), encoding="UTF-8", warn=FALSE)
rown = which(grepl(emoji_regex, text, useBytes=TRUE))
text_emoji_lines <- text[which(grepl(emoji_regex, text, useBytes=TRUE))]
found_emoji <- ore.search(compiled, text_emoji_lines, all=TRUE)
#matches function both in ore and dplyer, use ore only
emoji_matches <- matches(found_emoji)

###################### prepare
#contains pipe, and different matches function than ore
library(dplyr)
#contains map_chr function
library(purrr)
#contains flatten_chr function
library(tidyr)
#dataframe with multivalue list column
dfe = data.frame(id=rown, list=I(emoji_matches))
#flatten multi-value column
dfe = unnest(dfe, list)
#get emoji codes
dfe$ecode = flatten_chr(emoji_matches) %>% 
    map(charToRaw) %>% 
    map(as.character) %>% 
    map(toupper) %>% 
    map(~sprintf("\\x%s", .x)) %>% 
    map_chr(paste0, collapse="")
#join emoji code, description
colnames(emoji)[2] = "ecode"
dfe = left_join(dfe, emoji, by="ecode")
#aggregate, concatenate emojis by post id
#dfa = aggregate(V3 ~ id, FUN=paste, collapse=" ", data=dfe)
#dfa = aggregate(V3 ~ id, FUN=function(x) { c(edesc=paste(x), enum=length(x)) }, data=dfe)
dfa = cbind(aggregate(V3 ~ id, FUN=paste, collapse=" ", data=dfe), enum=aggregate(V3 ~ id, FUN=length, data=dfe))

###################### execute
#get original data
#dfo = read.table('csv/civil-society-190415.csv', sep='\t', header=T, strip.white=TRUE, stringsAsFactors=FALSE)
#compare with processed data
#dfp = read.table('csv/sa-190605.csv', sep='\t', header=T, strip.white=TRUE, stringsAsFactors=FALSE)
#emoticons are preserved
#dfo = read.table('csv/fb-emo-norm-sample.csv', sep='\t', quote="\"", header=T, strip.white=TRUE, stringsAsFactors=FALSE)
# 210218 fix to facilitate reading fb data into R
#!for i in $(seq 30); do cut -f"$i" csv/fb-emo-norm-sample.csv > tmp/field-$i.csv; done
#!for i in 3 21 22 26 27; do sed -i -e 's/"//g' -e 's/^/"/g' -e 's/$/"/g' tmp/field-$i.csv; done
for (i in c(1:31)) { dfi = read.table(paste0('tmp/field-', fb, "-", i, '.csv'), sep='\t', quote="\"", header=F, strip.white=TRUE, stringsAsFactors=FALSE, blank.lines.skip=F); colnames(dfi)[1] = paste0("field_", i); if (i == 1) { dfj = dfi; next } else { dfj = cbind(dfj, dfi) } }
dfo = dfj
#add languange col, diffrent encodings of multibyte chars (mswin/macos?), literally dont change regex
dfo$post_lang = ifelse(grepl("å|å|ä|ä|ö|ö", dfo$field_23, ignore.case=TRUE), "sv", "en")
#connect emoji data to orginal dataset
dfo$emoji = NA
dfo$emnum = 0
for (i in 1:nrow(dfa)) {
dfo$emoji[dfa$id[i]] = dfa$V3[i]
dfo$emnum[dfa$id[i]] = dfa$enum.V3[i]
}
#add emoji descriptions to text data
#not good since swedish and english language gets mixed
#dfo$etext = paste(dfo$post_message, dfo$emoji, sep=" ")
#match columns to ~/dev/r-cran/scom-org/csv/civil-society-191118.csv dataset

#['post_id','post_message','by','post_published_unix','post_lang',\
#"likes_count_fb","comments_count_fb","reactions_count_fb","shares_count_fb","engagement_fb","emoji","emnum"]

#export data
write.table(dfo, paste0("csv/fb-emoji-", fb, ".csv"), sep="\t", col.names=F, row.names=F)
#
}

#~ ##################################################################### 200304
get_aggregated <- function(dfm) {
#aggregate all variables in single dataframe
dfa = as.data.frame(unique(dfm$bins))
colnames(dfa)[1] = "bins"
dfa$month = seq(length(dfa$bins))
#time, engagement
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$e_score %in% boxplot(dfm$e_score, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(e_score ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#word count
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$wc %in% boxplot(dfm$wc, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(wc ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#valence
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$sa_val %in% boxplot(dfm$sa_val, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(sa_val ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#intensity
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$sa_int %in% boxplot(dfm$sa_int, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(sa_int ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#frequency
dfm$sa_out = ifelse(rownames(dfm) %in% which(dfm$sa_frq %in% boxplot(dfm$sa_frq, plot=FALSE)$out), 1, 0)
dfa = cbind(dfa, aggregate(sa_frq ~ bins, FUN=mean, data=subset(dfm, sa_out!=1))[2])
#emoji num, no outlier analysis
dfa = cbind(dfa, aggregate(emnum ~ bins, FUN=mean, data=dfm)[2])
# select 5*12 months
dfa = dfa[1:60,]
#
return(dfa)
}

# customize upper panel
panel.upper <- function(x, y) {
points(x, y, pch=19, col=df$col)
}

# correlation panel
panel.cor <- function(x, y) {
usr <- par("usr"); on.exit(par(usr))
par(usr = c(0, 1, 0, 1))
r <- round(cor(x, y), digits=2)
txt <- paste0("R=", r)
#cex.cor <- 0.8/strwidth(txt)
#text(0.5, 0.5, txt, cex = cex.cor * r)
text(0.5, 0.5, txt, cex=1.5)
}

#~ ##################################################################### 200228
getpvals_lmer <- function(m) {
#coefs
coefs <- data.frame(coef(summary(m)))
# use normal distribution to approximate p-value
coefs$p.z <- 2 * (1 - pnorm(abs(coefs$t.value)))
#round
mp = round(coefs, 3)
#
return(mp)
}

#~ ##################################################################### 191119
#library(tidytext)

get_data <- function(fn='csv/sa-191120.csv') {
#read data
dfm = read.table(fn, sep='\t', header=T, strip.white=TRUE, stringsAsFactors=FALSE)
#dfm$sa_pos[dfm$sa_pos==0] = NA
#get post word count
dfm$wc = sapply(strsplit(dfm$text, " "), length)
#new dependent measures, emotional intensity
dfm$sa_int = dfm$sa_pos + abs(dfm$sa_neg)
#relative to post word count
dfm$sa_int_rel = dfm$sa_int / dfm$wc
dfm$sa_frq_rel = dfm$sa_frq / dfm$wc
#index
dfm$index = seq(length(dfm$group))
#use date bins value for rank order month
dfm$month = as.numeric(as.factor(dfm$bins))
#suggest outliers
dfm$out = 0
dfm$out[(rownames(dfm) %in% which(dfm$e_score %in% boxplot(dfm$e_score, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$wc %in% boxplot(dfm$wc, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$sa_val %in% boxplot(dfm$sa_val, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$sa_int %in% boxplot(dfm$sa_int, plot=FALSE)$out))] = 1
dfm$out[(rownames(dfm) %in% which(dfm$sa_frq %in% boxplot(dfm$sa_frq, plot=FALSE)$out))] = 1
#dfm$out[(rownames(dfm) %in% which(dfm$emnum %in% boxplot(dfm$emnum, plot=FALSE)$out))] = 1
#export data
#write.table(dfm, "/tmp/scom/sa-cases-190605.csv", sep="\t", row.names=F)
#
return(dfm)
}

normalize <- function(x) {return ((x - min(x)) / (max(x) - min(x)))}

#~ ##################################################################### 190606

get_texts <- function(fn='csv/netvizz.tsv') {
#read data
dfm = read.table(fn, sep='\t', header=T, strip.white=TRUE, stringsAsFactors=FALSE)
#subset columns
#dfm = dfm[, c(19,1,8,4)]
#
return(dfm)
}

get_match <- function(df, pattern='word', type='rowid') {
#text col need to be named text
out = dfs[grep(pattern, dfs$postmessage),]
#only row names
out = grep(pattern, dfs$postmessage)
#
return(out)
}

get_tokens <- function(tbl, type='word') { # possibly type='sentence'
#text col need to be named text
tblt = tbl %>% unnest_tokens("word", postmessage)
#show result
head(tblt)
#
return(tblt)
}

get_stems <- function(tbl, lang='en') {
#text col need to be named text
tblt = tbl %>% unnest_tokens("word", postmessage)
#show result
head(tblt)
#
return(tblt)
}

get_topics <- function(tbl, lang='en') {
#text col need to be named text
tblt = tbl %>% unnest_tokens("word", postmessage)
#show result
head(tblt)
#
return(tblt)
}

get_sents <- function(tbl, lang='en') {
#text col need to be named text
tblt = tbl %>% unnest_tokens("word", postmessage)
#show result
head(tblt)
#
return(tblt)
}

get_dfm <- function(tbl, lang='en') {
#document-feature matrix (dfm)
#document-term matrix (dtm)
tblt = tbl %>% unnest_tokens("word", postmessage)
#show result
head(tblt)
#
return(tblt)
}




