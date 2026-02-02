fanshishi <- function(betamatrix,A,rsp,hrz,nvar,lag_order,vc,shock,method = "KL"){
  for (i in 1:1) {
    # 创建一个列表来存储每个滞后的系数矩阵
    beta_matrices <- list()
  alphamatrix=diag(ncol(A))-A
  for (j in 1:lag_order) {
    beta_matrices[[j]] <- betamatrix[,(nvar*j-(nvar-1)):(nvar*j)]
  }
  # 创建列表来存储向量
  y_list <- vector("list", hrz)
  yy_list <- vector("list", hrz)
  # 使用循环创建向量并存储在列表中
  for (k in 1:hrz) {
    y_list[[k]] <- matrix(NaN,nvar,1)
    yy_list[[k]] <- matrix(NaN,nvar,1)
  }
  
  betamatrix_KL=beta_matrices;  alphamatrix_KL =alphamatrix
  betamatrix_BGW=beta_matrices; alphamatrix_BGW=alphamatrix
  for (j in 1:lag_order) {
    betamatrix_KL[[j]][vc, shock] <- 0
  }######KL方法
  alphamatrix_KL[vc, shock] <- 0
  
  for (j in 1:lag_order) {
    for (k in 1:nvar) {
      betamatrix_BGW[[j]][vc, k] <- 0
    }
  }
  # 循环设置 alphamatrix 中的特定行的所有元素为 0
  for (k in 1:nvar) {
    alphamatrix_BGW[vc, k] <- 0
  }
  
  # 创建一个列表来存储累积的矩阵
  cumulative_betamatrix_KL <- list()
  cumulative_betamatrix_KL[[1]] = betamatrix_KL[[1]]
  betamatrix1=betamatrix_KL[[1]]
  
  cumulative_betamatrix_BGW <- list()
  cumulative_betamatrix_BGW[[1]] = betamatrix_BGW[[1]]
  betamatrix2=betamatrix_BGW[[1]]
  
  # 循环拼接剩余滞后期的系数矩阵
  for (k in 2:lag_order) {
    betamatrix1 <- cbind(betamatrix1, betamatrix_KL[[k]])
    cumulative_betamatrix_KL[[k]] <- betamatrix1
    
    betamatrix2 <- cbind(betamatrix2, betamatrix_BGW[[k]])
    cumulative_betamatrix_BGW[[k]] <- betamatrix2
  }}######生成一些约束过0的矩阵为反事实装备
#'=== Direct Approach ===
#'
########## '=== Contemporaneously counterfactual responses ===
# 根据method选择alphamatrix和betamatrix
if (method == "KL") {
  alphamatrix <- alphamatrix_KL
  betamatrix <- cumulative_betamatrix_KL[[lag_order]]
} else if (method == "BGW") {
  alphamatrix <- alphamatrix_BGW
  betamatrix <- cumulative_betamatrix_BGW[[lag_order]]
} else {
  stop("Invalid method. Please choose 'KL' or 'BGW'.")
}
##******************************************************************##这块根据情况修改
y_list[[1]][1] =rsp[1,1]
y_list[[1]][2] =rsp[1,2]
y_list[[1]][3] =alphamatrix[3,1]*y_list[[1]][1] + alphamatrix[3,2]*y_list[[1]][2]
y_list[[1]][4] =alphamatrix[4,1]*y_list[[1]][1] + alphamatrix[4,2]*y_list[[1]][2] 
+alphamatrix[4,3]*y_list[[1]][3]
y_list[[1]][5] = 0
##******************************************************************##
##############' ==== Responses when h=<p ====######################## 
for (i in 1:1){
  y    <- matrix(0,nvar * lag_order,1)
  yall <- matrix(0,nvar * lag_order,1)
  
  for (j in 2:lag_order) {
    for (k in 1:(j - 1)) {
      kk <- j - k
      start_idx <- 1 + (k - 1) * nvar
      end_idx <- k * nvar
      y[start_idx:end_idx,1] <- y_list[[kk]]
    }
    yy_list[[j]] <- betamatrix %*% y
    y_list[[j]] <- solve(diag(nvar) - alphamatrix) %*% yy_list[[j]]
  }
  #Responses when h>p ====
  for (j in (lag_order + 1):hrz) {
    for (jj in 1:lag_order) {
      jjj <- j - jj
      start_idx <- 1 + (jj - 1) * nvar
      end_idx <- jj * nvar
      yall[start_idx:end_idx,1] <- y_list[[jjj]]
    }
    yy_list[[j]] <- betamatrix %*% yall
    y_list[[j]] <- solve(diag(nvar) - alphamatrix) %*% yy_list[[j]]
  }
  NEWIRF <- matrix(0, nrow = hrz, ncol = nvar)
  # 填充 NEWIRF 矩阵
  for (j in 1:hrz) {
    for (k in 1:nvar) {
      NEWIRF[j, k] <- y_list[[j]][k]
    }
  }
}
 ######以下部分不用更改，newirf输出
  list(NEWIRF=NEWIRF, rsp=rsp)
}