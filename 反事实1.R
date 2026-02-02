rm(list=ls())
library("svars")
library("ggplot2")
library("ggfortify")
library("openxlsx")
#note:1.数据读取规范2.找到A和系数矩阵,rsp 3.反事实分析注意rsp和newirf；4.BGW还是KL
load("fanshishi.rda")
################################
ldl.decomp <- function(A){
  R <- chol(A)
  D <- diag(diag(R))
  Linv <- solve(t(solve(D, R)))
  G <- D^2
  
  list(Linv=Linv, G=G)
}
data("USA", package = "svars")
RAW = read.xlsx("KL2011.xlsx", 2, detectDates=TRUE)
startnum=1
#DATE = as.Date(as.character(RAW[c(startnum:dim(RAW)[1]),1]))
Yreturn = ts(RAW[,-1],start=c(1967, 5), frequency=12)
USA=Yreturn
lag_order=12;nvar=5;hrz=25;shock=2;vc=5;
autoplot(USA, facets = TRUE) + theme_bw() + ylab("") #画折线图
VARselect(USA, lag.max = 10, type="const") #寻找滞后阶数
#这是为了测试svar的chol识别
v1 <- vars::VAR(USA, p=lag_order, type = "const")
usa.cv =id.chol(v1) 
u= (cbind(usa.cv$VAR$varresult$V1$residuals,usa.cv$VAR$varresult$V2$residuals,
          usa.cv$VAR$varresult$V3$residuals,usa.cv$VAR$varresult$V4$residuals,
          usa.cv$VAR$varresult$V5$residuals))#u需要修改
head(u)
A=ldl.decomp(cov(u))$Linv
betamatrix=A%*%usa.cv$A_hat[,-1]#去除const
alphamatrix=diag(ncol(USA))-A#yongused用于反事实分析

cores <- parallel::detectCores() - 1
set.seed(231)
usa.cv.boot <- wild.boot(usa.cv, #design = "recursive",# distr = "gaussian",
                         nboot = 100, n.ahead = 25, nc = cores)
plot(usa.cv.boot, lowerq = 0.05, upperq = 0.95,percentile = 'bonferroni')#脉冲响应
realIRF=usa.cv.boot$true
rsp=matrix(NaN,hrz,nvar);minzi=colnames(USA)
for (i in 1:nvar){
  rsp[,i]=realIRF$irf[[paste("epsilon[ ",minzi[shock]," ] %->% ",
                              minzi[i],sep = "")]]}

jqn=fanshishi(betamatrix,A,rsp,hrz,nvar,lag_order,vc,shock,method = "KL")

## write.table(jqn$rsp, "clipboard", sep="\t", row.names=FALSE)#把x读入剪贴板，包括名称；
## write.table(usa.cv[["A_hat"]], "clipboard", sep="\t", row.names=FALSE, col.names=FALSE)#不包括名称；