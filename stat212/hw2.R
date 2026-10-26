## STAT 212 HW 2, Problem 2
library(leaps)
dir.create("figs", showWarnings = FALSE)

bb <- read.csv("Baseball-Salary-Data.csv", check.names = TRUE)
n  <- nrow(bb)
y  <- bb$salary
X  <- as.matrix(bb[, !(names(bb) %in% c("salary", "player"))])
k  <- ncol(X)

## ---- (a) best subsets via leaps ----------------------------------------
## best model of each size (by R^2, equivalently RSS)
ls1 <- leaps(X, y, method = "r2", nbest = 1, names = colnames(X))

## AIC / BIC for each best-subset model (same idea as leaps.AIC)
SST  <- sum((y - mean(y))^2)
RSS  <- (1 - ls1$r2) * SST
p    <- ls1$size                     # number of coefficients incl. intercept
AIC  <- n * log(RSS / n) + 2 * p
BIC  <- n * log(RSS / n) + log(n) * p
adjR2 <- leaps(X, y, method = "adjr2", nbest = 1, names = colnames(X))$adjr2

tab <- data.frame(npred = p - 1, R2 = ls1$r2, adjR2 = adjR2,
                  AIC = AIC, BIC = BIC)
print(round(tab, 3))
cat("AIC min size:", tab$npred[which.min(AIC)],
    " BIC min size:", tab$npred[which.min(BIC)], "\n")
for (i in seq_len(nrow(tab)))
  cat(tab$npred[i], ":", colnames(X)[ls1$which[i, ]], "\n")

pdf("figs/criteria.pdf", width = 7, height = 3.2)
par(mfrow = c(1, 2), mar = c(4, 4, 2, 1))
plot(tab$npred, tab$AIC, type = "b", pch = 19, xlab = "# predictors", ylab = "AIC", main = "AIC")
abline(v = tab$npred[which.min(AIC)], lty = 2)
plot(tab$npred, tab$BIC, type = "b", pch = 19, xlab = "# predictors", ylab = "BIC", main = "BIC")
abline(v = tab$npred[which.min(BIC)], lty = 2)
dev.off()

save(tab, ls1, file = "leaps_out.RData")

## ---- chosen model: BIC-optimal 6-predictor model ------------------------
fit <- lm(salary ~ home.runs + rbi + strike.outs + stolen.bases +
            free.agent.eligible + arbitration.eligible, data = bb)
print(summary(fit))
## compare with the 9-predictor AIC model
fit9 <- lm(salary ~ home.runs + rbi + walks + strike.outs + stolen.bases +
             free.agent.eligible + free.agent + arbitration.eligible + arbitration, data = bb)
print(anova(fit, fit9))

## ---- (b) standardized residuals vs index --------------------------------
r   <- rstandard(fit)
big <- which(abs(r) > 3)
pdf("figs/resid_index.pdf", width = 7, height = 4)
par(mar = c(4, 4, 1, 1))
plot(1:n, r, pch = 19, cex = 0.6, xlab = "Index", ylab = "Standardized residual")
abline(h = c(-3, 0, 3), lty = c(2, 1, 2))
text(big, r[big], bb$player[big], pos = 4, cex = 0.7)
dev.off()
out <- data.frame(idx = big, player = bb$player[big], salary = bb$salary[big],
                  fitted = round(fitted(fit)[big]), std.res = round(r[big], 2),
                  bb[big, c("home.runs","rbi","strike.outs","stolen.bases",
                            "free.agent.eligible","arbitration.eligible","free.agent")])
print(out)
## compare to population
print(summary(bb$salary)); print(quantile(bb$salary, c(.9,.95,.99)))
print(colMeans(bb[, c("salary","home.runs","rbi","free.agent.eligible","arbitration.eligible","free.agent")]))
print(rank(-bb$salary)[big])

## ---- (c) residuals vs fitted, QQ plot -----------------------------------
pdf("figs/resid_fitted.pdf", width = 5.5, height = 4.5)
par(mar = c(4, 4, 1, 1))
plot(fitted(fit), r, pch = 19, cex = 0.6, xlab = "Fitted salary", ylab = "Standardized residual")
abline(h = 0); abline(h = c(-3, 3), lty = 2)
lines(lowess(fitted(fit), r), col = "red", lwd = 2)
dev.off()
pdf("figs/qq.pdf", width = 5.5, height = 4.5)
par(mar = c(4, 4, 1, 1))
qqnorm(r, pch = 19, cex = 0.6, main = ""); qqline(r, lwd = 2)
dev.off()
cat("min fitted:", min(fitted(fit)), " # negative fitted:", sum(fitted(fit) < 0), "\n")
cat("skew of r:", mean((r-mean(r))^3)/sd(r)^3, "\n")
print(shapiro.test(r))
## spread by fitted tercile
print(tapply(r, cut(fitted(fit), quantile(fitted(fit), 0:3/3), include.lowest=TRUE), sd))

## ---- (d) Cook's distance ------------------------------------------------
D <- cooks.distance(fit)
pdf("figs/cooks.pdf", width = 7, height = 4)
par(mar = c(4, 4, 1, 1))
plot(1:n, D, type = "h", xlab = "Index", ylab = "Cook's D")
abline(h = 4 / n, lty = 2)
top <- order(D, decreasing = TRUE)[1:4]
text(top, D[top], bb$player[top], pos = 4, cex = 0.7)
dev.off()
cat("4/n =", 4/n, " max D =", max(D), " # D > 4/n:", sum(D > 4/n), "\n")
print(data.frame(player = bb$player[top], D = round(D[top], 4), std.res = round(r[top], 2),
                 lev = round(hatvalues(fit)[top], 3), salary = bb$salary[top]))
cat("F(0.5; p, n-p):", qf(0.5, 7, n - 7), "  2p/n =", 2*7/n, "\n")
## sensitivity: refit without the largest-D points
fit_drop <- update(fit, subset = -top)
print(round(cbind(full = coef(fit), dropped = coef(fit_drop)), 2))