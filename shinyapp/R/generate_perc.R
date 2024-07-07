library(tidyverse)
library(hrbrthemes)
library(zoo)
library(plotly)
library(shinycssloaders)



file <- readRDS("data/Percetilcurves_LR_mov.rds")

data <- file$file
mov_perc <- file$mov_perc



my_ggplot <- function(eTIV_file,volume_stat_file,age,sex) {
  
  fastsurfer_aseg <- read.csv(volume_stat_file, sep = "\t")
  eTIV <- read.csv(eTIV_file)

  
  df <- eTIV  %>%
    inner_join(fastsurfer_aseg, by = c("IDs" = "Measure.volume" ))
  
  
  
  vols_left <- df %>%
    mutate(hemisphere = "L",
           Frontal = ctx.lh.caudalmiddlefrontal + 
             ctx.lh.lateralorbitofrontal +
             ctx.lh.medialorbitofrontal +
             ctx.lh.parsopercularis +
             ctx.lh.parsorbitalis +
             ctx.lh.parstriangularis +
             ctx.lh.precentral +
             ctx.lh.rostralmiddlefrontal +
             ctx.lh.superiorfrontal,
           Temporal = ctx.lh.entorhinal +
             ctx.lh.fusiform +
             ctx.lh.inferiortemporal +
             ctx.lh.middletemporal +
             ctx.lh.parahippocampal +
             ctx.lh.superiortemporal +
             ctx.lh.transversetemporal +
             Left.Amygdala,
           Hippocampus = Left.Hippocampus,
           Paracentral = ctx.lh.paracentral,
           Parietal = ctx.lh.inferiorparietal +
             ctx.lh.postcentral +
             ctx.lh.precuneus +
             ctx.lh.superiorparietal +
             ctx.lh.supramarginal,
           Insula = ctx.lh.insula,
           Cingulate = ctx.lh.caudalanteriorcingulate +
             ctx.lh.isthmuscingulate +
             ctx.lh.posteriorcingulate +
             ctx.lh.rostralanteriorcingulate,
           Occipital = ctx.lh.cuneus +
             ctx.lh.lateraloccipital +
             ctx.lh.lingual +
             ctx.lh.pericalcarine,
           BasalGanglia = Left.Caudate + Left.Putamen +
             Left.Pallidum + Left.Accumbens.area,
           Thalamus = Left.Thalamus.Proper,
           Cerebellum = Left.Cerebellum.White.Matter +
             Left.Cerebellum.Cortex,
           CorpusCallosum = CC_Posterior + CC_Mid_Posterior + CC_Central + CC_Mid_Anterior + CC_Anterior,
           Ventricles = Left.Lateral.Ventricle + 
             Left.Inf.Lat.Vent +
             Left.choroid.plexus +
             X3rd.Ventricle + X4th.Ventricle + CSF,
           VentralDC = Left.VentralDC + Left.VentralDC,
           WM = Left.Cerebral.White.Matter,
           Brainstem = Brain.Stem) %>%
    select(IDs, Frontal, Temporal, Hippocampus, Paracentral, Parietal, Insula, Cingulate, Occipital, BasalGanglia,
           Thalamus, Cerebellum, CorpusCallosum, Ventricles, VentralDC, WM, Brainstem, hemisphere) 
  
  
  vols_right <- df %>%
    mutate(hemisphere = "R",
           Frontal = ctx.rh.caudalmiddlefrontal + 
             ctx.rh.lateralorbitofrontal +
             ctx.rh.medialorbitofrontal +
             ctx.rh.parsopercularis +
             ctx.rh.parsorbitalis +
             ctx.rh.parstriangularis +
             ctx.rh.precentral +
             ctx.rh.rostralmiddlefrontal +
             ctx.rh.superiorfrontal,
           Temporal = ctx.rh.entorhinal +
             ctx.rh.fusiform +
             ctx.rh.inferiortemporal +
             ctx.rh.middletemporal +
             ctx.rh.parahippocampal +
             ctx.rh.superiortemporal +
             ctx.rh.transversetemporal +
             Right.Amygdala,
           Hippocampus = Right.Hippocampus,
           Paracentral = ctx.rh.paracentral,
           Parietal = ctx.rh.inferiorparietal +
             ctx.rh.postcentral +
             ctx.rh.precuneus +
             ctx.rh.superiorparietal +
             ctx.rh.supramarginal,
           Insula = ctx.rh.insula,
           Cingulate = ctx.rh.caudalanteriorcingulate +
             ctx.rh.isthmuscingulate +
             ctx.rh.posteriorcingulate +
             ctx.rh.rostralanteriorcingulate,
           Occipital = ctx.rh.cuneus +
             ctx.rh.lateraloccipital +
             ctx.rh.lingual +
             ctx.rh.pericalcarine,
           BasalGanglia = Right.Caudate + Right.Putamen +
             Right.Pallidum + Right.Accumbens.area,
           Thalamus = Right.Thalamus.Proper,
           Cerebellum = Right.Cerebellum.White.Matter +
             Right.Cerebellum.Cortex,
           CorpusCallosum = CC_Posterior + CC_Mid_Posterior + CC_Central + CC_Mid_Anterior + CC_Anterior,
           Ventricles = Right.Lateral.Ventricle + 
             Right.Inf.Lat.Vent +
             Right.choroid.plexus +
             X3rd.Ventricle + X4th.Ventricle + CSF,
           VentralDC = Left.VentralDC + Right.VentralDC,
           WM = Right.Cerebral.White.Matter,
           Brainstem = Brain.Stem) %>%
    select(IDs, Frontal, Temporal, Hippocampus, Paracentral, Parietal, Insula, Cingulate, Occipital, BasalGanglia,
           Thalamus, Cerebellum, CorpusCallosum, Ventricles, VentralDC, WM, Brainstem, hemisphere) 
  
  
  
  
  vols <- rbind(vols_right, vols_left) %>% merge(eTIV, by = "IDs")
  
  
  
  
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
    mutate (age = age)%>% 
    gather(key='ROI', value='Volume', -c(IDs, age, eTIV,hemisphere)) %>%
    arrange(ROI, age)  %>%
    mutate(hemisphere = case_when(
      ROI %in% c("CorpusCallosum", "Brainstem") ~ "c",
      TRUE ~ hemisphere
    )) ## make them one point in the plot
  
  
  

  
  
  # Prepare the data
  plot_data <- data %>%
    gather(key = 'ROI', value = 'Volume', -c(ids, age, sex, hemisphere, eTIV)) %>%
    arrange(ROI, age) %>%
    mutate(p05 = mov_perc$p05, p50 = mov_perc$p50, p95 = mov_perc$p95)
  
  # Create the plot
  p <- ggplot(plot_data, aes(x = age, y = Volume)) +
    geom_jitter(aes(shape = hemisphere), alpha=0.05) +
    geom_smooth(aes(x = age, y = p05), color = 'black', se = FALSE, method = 'loess', span = 1, size = 0.5) +
    geom_smooth(aes(x = age, y = p50), color = 'black', se = FALSE, method = 'loess', span = 1, size = 0.5) +
    geom_smooth(aes(x = age, y = p95), color = 'black', se = FALSE, method = 'loess', span = 1, size = 0.5) +
    
    geom_point(data = point, aes(x = age, y = Volume, shape = hemisphere, color = hemisphere
    ),
    alpha = 0.8,
    size =3) +
    facet_wrap(~ROI, scales = 'free_y', ncol = 4) + # Adjust ncol to fit more panels
    xlab("Age (year)") +
    ylab("") +
    theme_ipsum() +
    theme(
      axis.text.x = element_text(size = 10),
      axis.title.x = element_text(size = 16),
      legend.position = 'none',
      panel.spacing.x = unit(-0.95, "cm"),
      panel.spacing.y = unit(-0.1, "cm"),
      plot.margin = margin(0, 0, 1, 0, "cm"),

      strip.background = element_blank() # Remove background of facet labels
    )
  
  return(p)
}
