## ----setup, include=FALSE------------------------------------------------
knitr::opts_chunk$set(echo = TRUE, warning = FALSE)

## ----CRAN installation instructions, eval = FALSE------------------------
#  install.packages("rEDM")

## ----GitHub installation instructions, eval = FALSE----------------------
#  devtools::install_github("ha0ye/rEDM")

## ----fig_time_series_projection, echo = FALSE, fig.cap = "Time Series Projection from the Lorenz Attractor"----
knitr::include_graphics("figure_1.svg")

## ----fig_attractor_reconstruction, echo = FALSE, fig.cap = "Attractor Reconstruction from Lagged Coordinates"----
knitr::include_graphics("figure_2.svg")

## ----load tentmap data---------------------------------------------------
library(rEDM)
data(tentmap_del)
str(tentmap_del)

## ----lib and pred for tentmap--------------------------------------------
ts <- tentmap_del
lib <- c(1, 100)
pred <- c(201, 500)

## ----simplex on tentmap--------------------------------------------------
simplex_output <- simplex(ts, lib, pred)
str(simplex_output)

## ----rho vs. E for tentmap, tidy = TRUE, fig.width = 5, fig.height = 3.5----
par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0)) # set up margins for plotting
plot(simplex_output$E, simplex_output$rho, type = "l", xlab = "Embedding Dimension (E)", ylab = "Forecast Skill (rho)")

## ----simplex varying tp for tentmap--------------------------------------
simplex_output <- simplex(ts, lib, pred, E = 2, tp = 1:10)

## ----rho vs. tp for tentmap, tidy = TRUE, fig.width = 5, fig.height = 3.5----
par(mar = c(4,4,1,1))
plot(simplex_output$tp, simplex_output$rho, type = "l", 
     xlab = "Time to Prediction (tp)", ylab = "Forecast Skill (rho)")

## ----smap for tentmap----------------------------------------------------
smap_output <- s_map(ts, lib, pred, E = 2)

## ----rho vs. theta for tentmap, tidy = TRUE, fig.width = 5, fig.height = 3.5----
par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0))
plot(smap_output$theta, smap_output$rho, type = "l", 
     xlab = "Nonlinearity (theta)", ylab = "Forecast Skill (rho)")

## ----rho vs. theta with noise, tidy = TRUE, fig.width = 5, fig.height = 3.5----
ts <- ts + rnorm(length(ts), sd = sd(ts) * 0.2)
smap_output <- s_map(ts, lib, pred, E = 2)
par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0))
plot(smap_output$theta, smap_output$rho, type = "l", 
     xlab = "Nonlinearity (theta)", ylab = "Forecast Skill (rho)")

## ----load block_3sp data-------------------------------------------------
data(block_3sp)
str(block_3sp)

## ----block_lnlp for block_3sp, tidy = TRUE, warning = FALSE--------------
lib <- c(1, NROW(block_3sp))
pred <- c(1, NROW(block_3sp))

cols <- c(1, 2, 4) # c("x_t", "x_t-1", "y_t")
target <- 1 # "x_t"

block_lnlp_output <- block_lnlp(block_3sp, lib = lib, pred = pred, 
                                columns = cols, target_column = target, 
                                stats_only = FALSE, first_column_time = TRUE)

## ------------------------------------------------------------------------
str(block_lnlp_output)

## ----observed vs predicted for block_lnlp, tidy = TRUE, fig.width = 4, fig.height = 4----
observed <- block_lnlp_output$model_output[[1]]$obs
predicted <- block_lnlp_output$model_output[[1]]$pred

par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0), pty = "s")
plot_range <- range(c(observed, predicted), na.rm = TRUE)
plot(observed, predicted, xlim = plot_range, ylim = plot_range, 
     xlab = "Observed", ylab = "Predicted")
abline(a = 0, b = 1, lty = 2, col = "blue")

## ----sardine anchovy ccm, tidy = TRUE, warning = FALSE, cache = TRUE-----
data(sardine_anchovy_sst)
anchovy_xmap_sst <- ccm(sardine_anchovy_sst, E = 3, 
                        lib_column = "anchovy", target_column = "np_sst", 
                        lib_sizes = seq(10, 80, by = 10), num_samples = 100, 
                        random_libs = TRUE, replace = TRUE)
sst_xmap_anchovy <- ccm(sardine_anchovy_sst, E = 3, 
                        lib_column = "np_sst", target_column = "anchovy", 
                        lib_sizes = seq(10, 80, by = 10), num_samples = 100, 
                        random_libs = TRUE, replace = TRUE)
str(anchovy_xmap_sst)

## ----sardine anchovy ccm plot, tidy = TRUE, fig.width = 5, fig.height = 3.5----
a_xmap_t_means <- ccm_means(anchovy_xmap_sst)
t_xmap_a_means <- ccm_means(sst_xmap_anchovy)

par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0))
y1 <- pmax(0, a_xmap_t_means$rho)
y2 <- pmax(0, t_xmap_a_means$rho)

plot(a_xmap_t_means$lib_size, y1, type = "l", col = "red", 
     xlab = "Library Size", ylab = "Cross Map Skill (rho)", ylim = c(0, 0.25))
lines(t_xmap_a_means$lib_size, y2, col = "blue")
legend(x = "topleft", legend = c("anchovy xmap SST", "SST xmap anchovy"), 
       col = c("red", "blue"), lwd = 1, bty = "n", inset = 0.02, cex = 0.8)

## ----load e120 data, tidy = TRUE-----------------------------------------
data(e120_biodiversity)

normalize <- function(x, ...) {(x - mean(x, ...))/sd(x, ...)}

# separate time column from data
vars <- c("AbvBioAnnProd", "noh020tot", "invrichness", "SummerPrecip.mm.")
composite_ts <- e120_biodiversity[, vars]

# normalize each time series within a plot
data_by_plot <- split(composite_ts, e120_biodiversity$Plot)
normalized_data <- lapply(data_by_plot, function(df) sapply(df, normalize))
composite_ts <- cbind(Year = e120_biodiversity$Year, 
                      data.frame(do.call(rbind, normalized_data)))

## ----make composite library----------------------------------------------
segments_end <- cumsum(sapply(data_by_plot, NROW))
segments_begin <- c(1, segments_end[-length(segments_end)] + 1)
segments <- cbind(segments_begin, segments_end)

# Choose random segments for prediction
set.seed(2312)
rndlib <- sample(1:NROW(segments), floor(NROW(segments) * 0.75))
composite_lib <- segments[rndlib, ]
composite_pred <- segments[-rndlib, ]

## ------------------------------------------------------------------------
precip_ts <- unique(e120_biodiversity[, c("Year", "SummerPrecip.mm.")])
precip_ts <- precip_ts[order(precip_ts$Year), ]

## ----simplex on e120, tidy = TRUE, warning = FALSE, fig.width = 6--------
simplex_out <- lapply(names(composite_ts)[2:4], function(var) {
    simplex(composite_ts[, c("Year", var)], E = 2:4, 
            lib = composite_lib, pred = composite_pred)
})
simplex_out[[length(simplex_out) + 1]] <- simplex(precip_ts, E = 2:5)
names(simplex_out) <- names(composite_ts)[-1]

par(mar = c(4, 4, 1, 1), mfrow = c(2, 2), mgp = c(2.5, 1, 0))
out <- lapply(names(simplex_out), function(var) {
    plot(simplex_out[[var]]$E, simplex_out[[var]]$rho, type = "l", 
         xlab = "Embedding Dimension (E)", ylab = "Forecast Skill (rho)", 
         main = var)
})

## ----best E for e120-----------------------------------------------------
best_E <- sapply(simplex_out, function(df) {df$E[which.max(df$rho)]})
best_E

## ----smap on e120, cache = TRUE, warning = FALSE, tidy = TRUE, fig.width = 6, results = "hide"----
smap_out <- lapply(names(composite_ts)[2:4], function(var) {
    s_map(composite_ts[, c("Year", var)], E = best_E[var], 
            lib = composite_lib, pred = composite_pred)
})
smap_out[[length(smap_out)+1]] <- s_map(precip_ts, E = best_E[length(smap_out)+1])
names(smap_out) <- names(simplex_out)

par(mar = c(4, 4, 1, 1), mfrow = c(2, 2), mgp = c(2.5, 1, 0)) # set up margins for plotting
lapply(names(smap_out), function(var) {
    plot(smap_out[[var]]$theta, smap_out[[var]]$rho, type = "l", 
         xlab = "Nonlinearity (theta)", ylab = "Forecast Skill (rho)", 
         main = var)
})

## ----make block for e120, tidy = TRUE------------------------------------
data_by_plot <- split(composite_ts, e120_biodiversity$Plot)
block_data <- do.call(rbind, lapply(data_by_plot, function(df) {
    n <- NROW(df)
    temp <- data.frame(Year = df$Year)
    temp$AB_tm <- df$AbvBioAnnProd
    temp$AB_tm1 <- c(NA, temp$AB_tm[-n])
    temp$AB_tm2 <- c(NA, temp$AB_tm1[-n])
    temp$AB_tm3 <- c(NA, temp$AB_tm2[-n])
    
    temp$NO_tm <- df$noh020tot
    temp$NO_tm1 <- c(NA, temp$NO_tm[-n])
    temp$NO_tm2 <- c(NA, temp$NO_tm1[-n])
    temp$NO_tm3 <- c(NA, temp$NO_tm2[-n])
    
    temp$IV_tm <- df$invrichness
    temp$IV_tm1 <- c(NA, temp$IV_tm[-n])
    temp$IV_tm2 <- c(NA, temp$IV_tm1[-n])
    temp$IV_tm3 <- c(NA, temp$IV_tm2[-n])
    
    temp$PR_tm <- df$SummerPrecip.mm
    temp$PR_tm1 <- c(NA, temp$PR_tm[-n])
    temp$PR_tm2 <- c(NA, temp$PR_tm1[-n])
    temp$PR_tm3 <- c(NA, temp$PR_tm2[-n])
    
    return(temp)
}))
head(block_data[, 1:5], 20)

## ----block_lnlp for e120, tidy=TRUE, warning = FALSE, cache = TRUE-------
AB_columns <- c("AB_tm", "AB_tm1", "AB_tm2")
AB_output <- block_lnlp(block_data, lib = composite_lib, pred = composite_pred, 
                        columns = AB_columns, target_column = 1, 
                        stats_only = FALSE, first_column_time = TRUE)

ABNO_columns <- c("AB_tm", "AB_tm1", "AB_tm2", "NO_tm", "NO_tm1", "NO_tm2")
ABNO_output <- block_lnlp(block_data, lib = composite_lib, pred = composite_pred, 
                          columns = ABNO_columns, target_column = 1, 
                          stats_only = FALSE, first_column_time = TRUE)


## ----block_lnlp on e120, tidy = TRUE, warning = FALSE, fig.width = 4, fig.height = 4----
observed_AB <- AB_output$model_output[[1]]$obs
predicted_AB <- AB_output$model_output[[1]]$pred

observed_ABNO <- ABNO_output$model_output[[1]]$obs
predicted_ABNO <- ABNO_output$model_output[[1]]$pred

par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0), pty = "s") # set up margins for plotting
plot_range <- range(c(observed_AB, predicted_AB), na.rm = TRUE)
plot(observed_AB, predicted_AB, xlim = plot_range, ylim = plot_range, 
     xlab = "Observed", ylab = "Predicted")
abline(a = 0, b = 1, lty = 2, col = "darkgrey", lwd = 2)
abline(lm(predicted_AB ~ observed_AB), col = "black", lty = 3, lwd = 2)

points(observed_ABNO, predicted_ABNO, pch = 2, col = "red")
abline(lm(predicted_ABNO ~ observed_ABNO), col = "red", lty = 3, lwd = 2)

legend("topleft", legend = c(paste("rho =", round(AB_output$rho, 2)), 
                             paste("rho =", round(ABNO_output$rho, 2))), 
       lty = 3, lwd = 2, col = c("black", "red"), bty = "n")

## ----ccm on e120, cache = TRUE, warning = FALSE, tidy = TRUE, fig.width = 5, fig.height = 3.5----
# A. repens:
my_lib_sizes <- c(seq(5, 55, by = 2), seq(55, 400, by = 50))

no_xmap_inv <- ccm(composite_ts, lib = segments, pred = segments, 
                   lib_column = "noh020tot", target_column = "invrichness", 
                   E = best_E["noh020tot"], lib_sizes = my_lib_sizes, silent = TRUE)
inv_xmap_no <- ccm(composite_ts, lib = segments, pred = segments, 
                   lib_column = "invrichness", target_column = "noh020tot", 
                   E = best_E["invrichness"], lib_sizes = my_lib_sizes, silent = TRUE)

n_xmap_i_means <- ccm_means(no_xmap_inv)
i_xmap_n_means <- ccm_means(inv_xmap_no)

par(mar = c(4, 4, 1, 1)) # set up margins for plotting
plot(n_xmap_i_means$lib_size, pmax(0, n_xmap_i_means$rho), type = "l", 
     xlab = "Library Size", ylab = "Cross Map Skill (rho)", 
     col = "red", ylim = c(0, 0.4), lwd = 2)
lines(i_xmap_n_means$lib_size, pmax(0, i_xmap_n_means$rho), 
      col = "blue", lwd = 2)
legend(x = "topleft", col = c("red", "blue"), lwd = 2, 
       legend = c("Nitrate xmap Inv. Richness", "Inv. Richness xmap Nitrate"), 
       inset = 0.02, bty = "n", cex = 0.8)

## ----ccm on e120 with biological productivity, cache = TRUE, warning = FALSE, tidy = TRUE, fig.width = 5, fig.height = 3.5----
ab_xmap_inv <- ccm(composite_ts, lib = segments, pred = segments,
                   lib_column = "AbvBioAnnProd", target_column = "invrichness", 
                   E = best_E["AbvBioAnnProd"], lib_sizes = my_lib_sizes, silent = TRUE)
inv_xmap_ab <- ccm(composite_ts, lib = segments, pred = segments, 
                   lib_column = "invrichness", target_column = "AbvBioAnnProd", 
                   E = best_E["invrichness"], lib_sizes = my_lib_sizes, silent = TRUE)

a_xmap_i_means <- ccm_means(ab_xmap_inv)
i_xmap_a_means <- ccm_means(inv_xmap_ab)

par(mar = c(4, 4, 1, 1)) # set up margins for plotting
plot(a_xmap_i_means$lib_size, pmax(0, a_xmap_i_means$rho), type = "l", 
     xlab = "Library Size", ylab = "Cross Map Skill (rho)", 
     col = "orange", ylim = c(0, 0.4), lwd = 2)
lines(i_xmap_a_means$lib_size, pmax(0, i_xmap_a_means$rho), 
      col = "blue", lwd = 2)
legend(x = "topleft", col = c("orange", "blue"), 
       legend = c("Abv. Biomass xmap Inv. Richness", 
                  "Inv. Richness xmap Abv. Biomass"), 
       lwd = 2, inset = 0.02, bty = "n", cex = 0.8)

## ----thrips data---------------------------------------------------------
data(thrips_block)
colnames(thrips_block)

## ----thrips plot, echo = FALSE, fig.width = 6, fig.height = 7------------
par(mfrow = c(4, 1), mar = c(4, 4, 1, 1), oma = c(2, 0, 0, 0), mgp = c(2.5, 1, 0))
time_dec <- thrips_block$Year + (thrips_block$Month)/12
plot(time_dec, thrips_block$Thrips_imaginis, type = "l", col = "green", ylab = "Thrips", xlab = "")
plot(time_dec, thrips_block$maxT_degC, type = "l", col = "red", ylab = "maxT (oC)", xlab = "")
plot(time_dec, thrips_block$Rain_mm, type = "l", col = "blue", ylab = "Rain (mm)", xlab = "")
plot(time_dec, thrips_block$Season, type = "l", col = "magenta", ylab = "Season")
mtext("Year", side = 1, outer = TRUE, line = 1)

## ----univariate thrips, warning = FALSE----------------------------------
ts <- thrips_block$Thrips_imaginis
lib <- c(1, length(ts))
pred <- c(1, length(ts))
simplex_output <- simplex(ts, lib, pred, tau = 1)

## ----rho vs. e for thrips, echo=FALSE, fig.width = 5, fig.height = 3.5, tidy = TRUE----
par(mar = c(4,4,1,1))
plot(simplex_output$E, simplex_output$rho, type = "l", 
     xlab = "Embedding Dimension (E)", ylab = "Forecast Skill (rho)")

## ----smap for thrips, warning = FALSE------------------------------------
smap_output <- list()
smap_output[[1]] <- s_map(ts, lib, pred, E = 4)
smap_output[[2]] <- s_map(ts, lib, pred, E = 8)

## ----rho vs. theta for thrips, echo=FALSE, tidy = TRUE, fig.width = 6, fig.height = 3.5----
par(mar = c(4, 4, 1, 1), mfrow = c(1, 2))
plot(smap_output[[1]]$theta, smap_output[[1]]$rho, type = "l", xlim = c(0, 4), 
     xlab = "Nonlinearity (theta)", ylab = "Forecast Skill (rho)")
plot(smap_output[[2]]$theta, smap_output[[2]]$rho, type = "l", xlim = c(0, 4), 
     xlab = "Nonlinearity (theta)", ylab = "Forecast Skill (rho)")

## ----compute ccm matrix for thrips, results='hold', tidy=TRUE, cache = TRUE, warning = FALSE----
vars <- colnames(thrips_block[3:6])
n <- NROW(thrips_block)
ccm_matrix <- array(NA, dim = c(length(vars), length(vars)), 
                    dimnames = list(vars, vars))

for(ccm_from in vars)
{
    for(ccm_to in vars[vars != ccm_from])
    {
        out_temp <- ccm(thrips_block, E = 8, 
                        lib_column = ccm_from, target_column = ccm_to,
                        lib_sizes = n, replace = FALSE, silent = TRUE)
        ccm_matrix[ccm_from, ccm_to] <- out_temp$rho
    }
}

## ----compute corr matrix for thrips, tidy=TRUE---------------------------
corr_matrix <- array(NA, dim = c(length(vars), length(vars)), 
                     dimnames = list(vars, vars))

for(ccm_from in vars)
{
    for(ccm_to in vars[vars != ccm_from])
    {
        cf_temp <- ccf(thrips_block[,ccm_from], thrips_block[,ccm_to], 
                       type = "correlation", lag.max = 6, plot = FALSE)$acf
        corr_matrix[ccm_from, ccm_to] <- max(abs(cf_temp))
    }
}

## ----xmap vs. corr matrix for thrips-------------------------------------
head(ccm_matrix)
head(corr_matrix)

## ----ccm on thrips, results='hide', tidy=TRUE, cache = TRUE, warning=FALSE----
thrips_xmap_maxT <- ccm(thrips_block, E = 8, random_libs = TRUE, 
                        lib_column = "Thrips_imaginis", target_column = "maxT_degC", 
                        lib_sizes = seq(10, 75, by = 5), num_samples = 300)
maxT_xmap_thrips <- ccm(thrips_block, E = 8, random_libs = TRUE, 
                        lib_column = "maxT_degC", target_column = "Thrips_imaginis", 
                        lib_sizes = seq(10, 75, by = 5), num_samples = 300)

ccm_out <- list(ccm_means(thrips_xmap_maxT), ccm_means(maxT_xmap_thrips))

## ----ccm plot, echo=FALSE, tidy = TRUE, fig.width = 5, fig.height = 3.5----
par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0))
plot(ccm_out[[1]]$lib_size, pmax(0, ccm_out[[1]]$rho), type = "l", col = "red",  
     xlab = "Library Size", ylab = "Cross Map Skill (rho)", ylim = c(0, 1))
lines(ccm_out[[2]]$lib_size, pmax(0, ccm_out[[2]]$rho), col = "blue")
abline(h = corr_matrix['Thrips_imaginis', 'maxT_degC'], col = "black", lty = 2)
legend(x = "bottomright", legend = c("Thrips xmap maxT", "maxT xmap Thrips"), 
       col = c("red", "blue"), lwd = 1, inset = 0.02)

## ----ccm on thrips and rainfall, results='hide', tidy=TRUE, cache = TRUE, warning = FALSE----
thrips_xmap_Rain <- ccm(thrips_block, E = 8, random_libs = TRUE, 
                        lib_column = "Thrips_imaginis", target_column = "Rain_mm", 
                        lib_sizes = seq(10, 75, by = 5), num_samples = 300)
Rain_xmap_thrips <- ccm(thrips_block, E = 8, random_libs = TRUE, 
                        lib_column = "Rain_mm", target_column = "Thrips_imaginis", 
                        lib_sizes = seq(10, 75, by = 5), num_samples = 300)

ccm_out <- list(ccm_means(thrips_xmap_Rain), ccm_means(Rain_xmap_thrips))

## ----rainfall and thrips ccm plot, echo=FALSE, tidy = TRUE, fig.width = 5, fig.height = 3.5----
par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0)) # set up margins for plotting
plot(ccm_out[[1]]$lib_size, pmax(0, ccm_out[[1]]$rho), type = "l", col = "red", 
     xlab = "Library Size", ylab = "Cross Map Skill (rho)", ylim = c(0, 1))
lines(ccm_out[[2]]$lib_size, pmax(0, ccm_out[[2]]$rho), col = "blue")
abline(h = corr_matrix['Thrips_imaginis','Rain_mm'], col = 'black', lty = 2)
legend(x = "topleft", legend = c("Thrips xmap Rain", "Rain xmap Thrips"),
 col = c("red", "blue"), lwd = 1, inset = 0.02)

## ----ccm on thrips and season, results='hide', tidy=TRUE, cache = TRUE, warning = FALSE----
thrips_xmap_Season <- ccm(thrips_block, E = 8, random_libs = TRUE, 
                          lib_column = "Thrips_imaginis", target_column = "Season", 
                          lib_sizes = seq(10, 75, by = 5), num_samples = 300)
Season_xmap_thrips <- ccm(thrips_block, E = 8, random_libs = TRUE, 
                          lib_column = "Season", target_column = "Thrips_imaginis", 
                          lib_sizes = seq(10, 75, by = 5), num_samples = 300)

ccm_out <- list(ccm_means(thrips_xmap_Season), ccm_means(Season_xmap_thrips))

## ----season and thrips ccm plot, echo=FALSE, fig.width = 5, fig.height = 3.5, tidy = TRUE----
par(mar = c(4, 4, 1, 1), mgp = c(2.5, 1, 0)) # set up margins for plotting
plot(ccm_out[[1]]$lib_size, pmax(0, ccm_out[[1]]$rho), type = "l", col = "red", 
     xlab = "Library Size", ylab = "Cross Map Skill (rho)", ylim = c(0, 1))
lines(ccm_out[[2]]$lib_size, pmax(0, ccm_out[[2]]$rho), col = "blue")
abline(h = corr_matrix['Thrips_imaginis', 'Season'], col = 'black', lty = 2)
legend(x = "bottomright", col = c("red", "blue"), lwd = 1, inset = 0.02, 
       legend = c("Thrips xmap Season", "Season xmap Thrips"))

## ----seasonal surrogates for thrips, cache = TRUE, warning = FALSE, tidy = TRUE----
num_surr <- 1000
surr_maxT <- make_surrogate_data(thrips_block$maxT_degC, method = "seasonal", T_period = 12, num_surr = num_surr)
surr_Rain <- make_surrogate_data(thrips_block$Rain_mm, method = "seasonal", T_period = 12, num_surr = num_surr)

rho_surr <- data.frame(maxT = numeric(num_surr), Rain = numeric(num_surr))

for (i in 1:num_surr) {
    rho_surr$maxT[i] <- ccm(cbind(thrips_block$Thrips_imaginis, surr_maxT[,i]), E = 8, lib_column = 1, target_column = 2, lib_sizes = NROW(thrips_block), replace = FALSE)$rho

    rho_surr$Rain[i] <- ccm(cbind(thrips_block$Thrips_imaginis, surr_Rain[,i]), E = 8, lib_column = 1, target_column = 2, lib_sizes = NROW(thrips_block), replace = FALSE)$rho
    }

## ----significance of randomization test----------------------------------
(sum(ccm_matrix['Thrips_imaginis','Rain_mm'] < rho_surr$Rain) + 1) / 
    (length(rho_surr$Rain) + 1)
(sum(ccm_matrix['Thrips_imaginis','maxT_degC'] < rho_surr$maxT) + 1) / 
    (length(rho_surr$maxT) + 1)

