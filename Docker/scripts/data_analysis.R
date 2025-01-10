# data_analysis.R



library(ggplot2)
library(dplyr)
library(methods)
library(tidyverse)
library(hrbrthemes)
library(zoo)

# Get the argument passed from the bash script
args <- commandArgs(trailingOnly = TRUE)
sub <- args[1]  # The first argument

# Get the exported environment variables
dest_dir <- Sys.getenv("dest_dir")
src_dir <- Sys.getenv("src_dir")

file <- readRDS("/opt/Percetilcurves_LR_mov.rds")
data <- file$file
mov_perc <- file$mov_perc



breaks_four <- function(x) {
  breaks <- seq(min(x), max(x), length.out = 5)
  breaks <- breaks[-1]  # Exclude the first break
  #breaks <- round(breaks,4)
  breaks[-c(0, length(breaks))]  # Exclude the last and first break
  
}



final_ggplot <- function(eTIV_file, volume_stat_file, age, sex) {
  
  fastsurfer_aseg <- read.csv(volume_stat_file, sep = "\t")
  eTIV <- read.csv(eTIV_file)
  
  df <- eTIV %>%
    inner_join(fastsurfer_aseg, by = c("IDs" = "Measure.volume"))
  
  # Left hemisphere volumes
  vols_left <- df %>%
    mutate(hemisphere = "L",
           Frontal = ctx.lh.caudalmiddlefrontal + ctx.lh.lateralorbitofrontal +
             ctx.lh.medialorbitofrontal + ctx.lh.parsopercularis +
             ctx.lh.parsorbitalis + ctx.lh.parstriangularis + 
             ctx.lh.precentral + ctx.lh.rostralmiddlefrontal + ctx.lh.superiorfrontal,
           Temporal = ctx.lh.entorhinal + ctx.lh.fusiform + ctx.lh.inferiortemporal +
             ctx.lh.middletemporal + ctx.lh.parahippocampal + ctx.lh.superiortemporal +
             ctx.lh.transversetemporal + Left.Amygdala,
           Hippocampus = Left.Hippocampus,
           Paracentral = ctx.lh.paracentral,
           Parietal = ctx.lh.inferiorparietal + ctx.lh.postcentral + ctx.lh.precuneus +
             ctx.lh.superiorparietal + ctx.lh.supramarginal,
           Insula = ctx.lh.insula,
           Cingulate = ctx.lh.caudalanteriorcingulate + ctx.lh.isthmuscingulate +
             ctx.lh.posteriorcingulate + ctx.lh.rostralanteriorcingulate,
           Occipital = ctx.lh.cuneus + ctx.lh.lateraloccipital + ctx.lh.lingual + ctx.lh.pericalcarine,
           BasalGanglia = Left.Caudate + Left.Putamen + Left.Pallidum + Left.Accumbens.area,
           Thalamus = Left.Thalamus,
           Cerebellum = Left.Cerebellum.White.Matter + Left.Cerebellum.Cortex,
           CorpusCallosum = CC_Posterior + CC_Mid_Posterior + CC_Central + CC_Mid_Anterior + CC_Anterior,
           Ventricles = Left.Lateral.Ventricle + Left.Inf.Lat.Vent + Left.choroid.plexus +
             X3rd.Ventricle + X4th.Ventricle + CSF,
           VentralDC = Left.VentralDC,
           WM = Left.Cerebral.White.Matter,
           Brainstem = Brain.Stem) %>%
    select(IDs, Frontal, Temporal, Hippocampus, Paracentral, Parietal, Insula, Cingulate, Occipital, BasalGanglia,
           Thalamus, Cerebellum, CorpusCallosum, Ventricles, VentralDC, WM, Brainstem, hemisphere)
  
  # Right hemisphere volumes
  vols_right <- df %>%
    mutate(hemisphere = "R",
           Frontal = ctx.rh.caudalmiddlefrontal + ctx.rh.lateralorbitofrontal +
             ctx.rh.medialorbitofrontal + ctx.rh.parsopercularis +
             ctx.rh.parsorbitalis + ctx.rh.parstriangularis +
             ctx.rh.precentral + ctx.rh.rostralmiddlefrontal + ctx.rh.superiorfrontal,
           Temporal = ctx.rh.entorhinal + ctx.rh.fusiform + ctx.rh.inferiortemporal +
             ctx.rh.middletemporal + ctx.rh.parahippocampal + ctx.rh.superiortemporal +
             ctx.rh.transversetemporal + Right.Amygdala,
           Hippocampus = Right.Hippocampus,
           Paracentral = ctx.rh.paracentral,
           Parietal = ctx.rh.inferiorparietal + ctx.rh.postcentral + ctx.rh.precuneus +
             ctx.rh.superiorparietal + ctx.rh.supramarginal,
           Insula = ctx.rh.insula,
           Cingulate = ctx.rh.caudalanteriorcingulate + ctx.rh.isthmuscingulate +
             ctx.rh.posteriorcingulate + ctx.rh.rostralanteriorcingulate,
           Occipital = ctx.rh.cuneus + ctx.rh.lateraloccipital + ctx.rh.lingual + ctx.rh.pericalcarine,
           BasalGanglia = Right.Caudate + Right.Putamen + Right.Pallidum + Right.Accumbens.area,
           Thalamus = Right.Thalamus,
           Cerebellum = Right.Cerebellum.White.Matter + Right.Cerebellum.Cortex,
           CorpusCallosum = CC_Posterior + CC_Mid_Posterior + CC_Central + CC_Mid_Anterior + CC_Anterior,
           Ventricles = Right.Lateral.Ventricle + Right.Inf.Lat.Vent + Right.choroid.plexus +
             X3rd.Ventricle + X4th.Ventricle + CSF,
           VentralDC = Right.VentralDC,
           WM = Right.Cerebral.White.Matter,
           Brainstem = Brain.Stem) %>%
    select(IDs, Frontal, Temporal, Hippocampus, Paracentral, Parietal, Insula, Cingulate, Occipital, BasalGanglia,
           Thalamus, Cerebellum, CorpusCallosum, Ventricles, VentralDC, WM, Brainstem, hemisphere)
  
  vols <- rbind(vols_right, vols_left) %>%
    merge(eTIV, by = "IDs")

  vols$VentralDC <- vols$VentralDC*2

  
#save cols
csv_path <- file.path(dest_dir, sub,"stats", "16_Volumes.csv")
write.csv(vols, file = csv_path, row.names = FALSE)
cat("Data exported to", csv_path, "successfully!\n")

  #normalization 
  
  vols <- vols %>%   mutate(
    across(
      c('Frontal', 'Temporal', 'Hippocampus', 'Paracentral', 
        'Parietal', 'Insula', 'Cingulate', 'Occipital', 'BasalGanglia', 
        'Thalamus', 'Cerebellum', 'CorpusCallosum', 'Ventricles', 
        'VentralDC', 'WM', 'Brainstem'),
      ~ . / (eTIV)
    )
  )
  
  
  point <- vols %>%
    mutate(age = age) %>%
    gather(key = 'ROI', value = 'Volume', -c(IDs, age, eTIV, hemisphere)) %>%
    arrange(ROI, age) %>%
    mutate(hemisphere = case_when(
      ROI %in% c("CorpusCallosum", "Brainstem") ~ "Brainstem / CorpusCallosum",
      hemisphere == "L" ~ "Left Hemisphere",
      hemisphere == "R" ~ "Right Hemisphere",
      TRUE ~ hemisphere  # Keep any other values unchanged    TRUE ~ hemisphere
    ))
  
  
  plot_data <- data %>%
    gather(key='ROI', value='Volume', -c(ids, age, sex, hemisphere, eTIV)) %>%
    mutate(hemisphere = case_when(
      ROI %in% c("CorpusCallosum", "Brainstem") ~ "Brainstem / CorpusCallosum",
      hemisphere == "L" ~ "Left Hemisphere",
      hemisphere == "R" ~ "Right Hemisphere",
      TRUE ~ hemisphere  # Keep any other values unchanged    TRUE ~ hemisphere
    )) %>%
    mutate(Volume = Volume*100) %>%
    arrange(ROI, age) %>%
    mutate(p05 = mov_perc$p05*100, p50 = mov_perc$p50*100, p95 = mov_perc$p95*100) %>%
    
    ggplot(aes(x=age, y=Volume, color=hemisphere))+
    geom_jitter(alpha=0.05, size =3, shape =19)+
    geom_smooth(aes(x=age, y=p05), color='black', se=F, method='loess', span = 1, linewidth=1.5)+
    geom_smooth(aes(x=age, y=p50), color='black', se=F, method='loess', span = 1, linewidth=1.5)+
    geom_smooth(aes(x=age, y=p95), color='black', se=F, method='loess', span = 1, linewidth=1.5)+
    geom_point(data = point, aes(x = age, y = Volume*100, color = hemisphere, shape = hemisphere),
               alpha = 0.8, size = 10) +
    
    facet_wrap(~ROI, scale='free_y')+
    ylab("ROI Volume / eTIV %") + 
    xlab("Age (years)")+
    theme_ipsum()+
    scale_x_continuous(breaks = c(seq(0, 18, by = 3))) + 
    scale_y_continuous(breaks = breaks_four, labels = function(x) sprintf("%.2f", x)) +
    scale_color_manual(values=c("Left Hemisphere"="blue", 
                                "Right Hemisphere"="red", 
                                "Brainstem / CorpusCallosum"="#31a354"))+
    theme(axis.title.x=element_text(size=28),
          axis.title.y=element_text(size=28),
          strip.text = element_text(size = 28, hjust = 0.5),
          axis.text.x = element_text(size=25),
          axis.text.y = element_text(size=25),
          panel.spacing = unit(0.1, "cm"),
          legend.position='bottom',
          legend.text = element_text(size=25),
          legend.spacing.x = unit(0.5, 'cm'),
          legend.title = element_blank()
    )  
  
  
  
  return(plot_data)
}

# Parameters
age <- args[2] %>% as.numeric
sex <- "Male"
volume_stat_file <- file.path(dest_dir, sub, "stats", "volume.stats.csv")
eTIV_file <- file.path(dest_dir, sub, "stats", "eTIV.stats.csv")

# Generate plot
plot <- final_ggplot(eTIV_file, volume_stat_file, age, sex)


# Save to ping
jpg_path <- file.path(dest_dir, sub, "GrowthChart.jpg")
ggsave(filename = jpg_path, plot = plot, width = 18, height = 18)
cat("Data exported to", jpg_path, "successfully!\n")



