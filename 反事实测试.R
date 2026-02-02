rm(list=ls())
library("svars")
library("ggplot2")
library("ggfortify")
library("openxlsx")
library(readxl)
#note:1.数据读取规范2.找到A和系数矩阵,rsp 3.反事实分析注意rsp和newirf；4.BGW还是KL
load("fanshishi3var.rda")
lag_order=2;nvar=3;hrz=13;shock=1;vc=2;
raw_A= as.matrix(read_excel("tvpvar_a.xlsx",range = "b5:d138",col_names = FALSE))
raw_B= as.matrix(read_excel("tvpvar_b.xlsx",range = "a3:r136",col_names = FALSE))
raw_rsp= as.matrix(read_excel("tvpvar_imp.xlsx",range = "c30:e1771",col_names = FALSE))
# 假设每一行数据代表不同时间点的下三角矩阵的元素
data <- raw_A
# 定义矩阵的维度 (例如3x3)
n <- nvar
# 创建还原下三角矩阵的函数
restore_lower_tri_matrix <- function(triangle_values, n) {
  mat <- matrix(0, n, n)  # 创建一个全0的 nxn 矩阵
  # 填充对角线为1
  diag(mat) <- 1
  # 填充下三角区域
  mat[lower.tri(mat)] <- triangle_values
  return(mat)
}
# 生成一个list，每个元素是还原的下三角矩阵
A <- lapply(1:nrow(data), function(i) {
  restore_lower_tri_matrix(data[i,], n)})
B = lapply(1:nrow(raw_B), function(i) {
  matrix(raw_B[i,], nrow = nvar,byrow = TRUE)})
rsp = lapply(1:nrow(raw_B), function(i) {
  as.matrix(raw_rsp[(13*i-12):(13*i),1:3])})

jqn <- lapply(1:nrow(raw_B), function(i) {
  fanshishi3var(B[[i]],A[[i]],rsp[[i]], hrz,nvar,lag_order,vc,shock,method = "BGW")})

rsp_mat=cbind(jqn[[1]]$rsp,jqn[[1]]$NEWIRF) #qu matlab draw
for (t in 2:nrow(raw_B)){
  tt = cbind(jqn[[t]]$rsp,jqn[[t]]$NEWIRF)
  rsp_mat = rbind(rsp_mat,tt)
}
colnames(rsp_mat) = c('irf_gpr2gpr','irf_gpr2remx','irf_gpr2new',
                      'irf1_gpr2gpr','irf1_gpr2remx','irf1_gpr2new')

#write.csv(as.matrix(rsp_mat),"result_fanshishi.xlsx")

#betamatrix = B[[1]]
#jqn=fanshishi3var(betamatrix,A[[1]],rsp,hrz,nvar,lag_order,vc,shock,method = "KL")

# write.table(jqn$rsp[,3], "clipboard", sep="\t", row.names=FALSE, col.names=FALSE)#不包括名称；
# write.table(jqn$NEWIRF[,3], "clipboard", sep="\t", row.names=FALSE, col.names=FALSE)#不包括名称；
df = data.frame(t = 0:12,irf = jqn$rsp[,3],newirf = jqn$NEWIRF[,3])
ggplot(df, aes(x = t)) +
  geom_line(aes(y = irf, color = 'irf1'), lwd=2) +
  geom_line(aes(y = newirf, color = 'irf2'), lwd=2) +
  scale_color_manual('Metric', values=c('steelblue','red')) +
  labs(title = 'fanshishi', x = 'horizon', y = 'irf') +
  theme_minimal()

