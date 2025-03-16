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

data <- readRDS("/fastsurfer/kinderseg/Percetilcurves_LR_mov.rds")
data <- data %>% rename(Hemisphere=hemisphere)


mov_perc <- data %>% 
gather(key='ROI', value='Volume', -c(ids, age, sex, Hemisphere, eTIV)) %>%
mutate(r_age = round(age,0)) %>%
arrange(ROI, age) %>%
group_by(ROI) %>%
summarize(p05=rollapply(Volume,5,quantile,prob=0.05, fill=NA),
          p50=rollapply(Volume,5,quantile,prob=0.50,fill=NA),
         p95=rollapply(Volume,5,quantile,prob=0.95,fill=NA))


breaks_four <- function(x) {
  breaks <- seq(min(x), max(x), length.out = 5)
  breaks <- breaks[-1]  # Exclude the first break
  #breaks <- round(breaks,4)
  breaks[-c(0, length(breaks))]  # Exclude the last and first break
  
}



final_ggplot <- function( volume_stat_file, age, sex) {
  
fastsurfer_aseg <- read.csv(volume_stat_file, sep = "\t") %>% 
    rename (sids = "Measure.volume") %>%
    rename (eTIV = "EstimatedTotalIntraCranialVol")

# Left hemisphere volumes
fastsurfer_absolute_summed_left_vols <- fastsurfer_aseg %>% 
  mutate(Frontal = ctx.lh.caudalmiddlefrontal + 
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
                Thalamus = Left.Thalamus,
                Cerebellum = Left.Cerebellum.White.Matter +
                              Left.Cerebellum.Cortex,
                Ventricles = Left.Lateral.Ventricle + 
                              Left.Inf.Lat.Vent +
                              Left.choroid.plexus +
                              X3rd.Ventricle + X4th.Ventricle + CSF,
                  VentralDC = Left.VentralDC + Left.VentralDC,
                  WM = Left.Cerebral.White.Matter + ((CC_Posterior + CC_Mid_Posterior + CC_Central + CC_Mid_Anterior + CC_Anterior)/2),
                  Brainstem = Brain.Stem) %>%
  select(sids, Frontal, Temporal, Hippocampus, Paracentral, Parietal, Insula, Cingulate, Occipital,, BasalGanglia,
            Thalamus, Cerebellum, Ventricles, VentralDC, WM, Brainstem, eTIV) 

# Right hemisphere volumes
fastsurfer_absolute_summed_right_vols <- fastsurfer_aseg %>% 
  mutate(Frontal = ctx.rh.caudalmiddlefrontal + 
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
                Thalamus = Right.Thalamus,
                Cerebellum = Right.Cerebellum.White.Matter +
                              Right.Cerebellum.Cortex,
                Ventricles = Right.Lateral.Ventricle + 
                              Right.Inf.Lat.Vent +
                              Right.choroid.plexus +
                              X3rd.Ventricle + X4th.Ventricle + CSF,
                  VentralDC = Left.VentralDC + Right.VentralDC,
                  WM = Right.Cerebral.White.Matter + ((CC_Posterior + CC_Mid_Posterior + CC_Central + CC_Mid_Anterior + CC_Anterior)/2),
                  Brainstem = Brain.Stem) %>%
  select(sids, Frontal, Temporal, Hippocampus, Paracentral, Parietal, Insula, Cingulate, Occipital,, BasalGanglia,
            Thalamus, Cerebellum, Ventricles, VentralDC, WM, Brainstem, eTIV)




##

vols <- rbind(fastsurfer_absolute_summed_right_vols %>% mutate(hemisphere = "R"),
              fastsurfer_absolute_summed_left_vols%>% mutate(hemisphere = "L")) 


  
#save cols
csv_path <- file.path(dest_dir, sub,"stats", "16_Volumes.csv")
write.csv(vols, file = csv_path, row.names = FALSE)
cat("Data exported to", csv_path, "successfully!\n")

  #normalization 
  
  vols <- vols %>%  
  mutate(across(.cols = -c(sids, hemisphere), .fns = ~ . / eTIV))

  
 point <- vols %>% 
    mutate (age = age)%>% 
    gather(key='ROI', value='Volume', -c(sids, age , eTIV,hemisphere)) %>%
    arrange(ROI, age)  %>%
      mutate(hemisphere = case_when(
                    ROI %in% c("Brainstem") ~ "Brainstem",
                  hemisphere == "L" ~ "Left Hemisphere",
                  hemisphere == "R" ~ "Right Hemisphere",
                  TRUE ~ hemisphere  # Keep any other values unchanged    TRUE ~ hemisphere
      ))%>%
      rename(Hemisphere=hemisphere)

  print (point)

  
  
  plot_data <- data %>% 
gather(key='ROI', value='Volume', -c(ids, age, sex, Hemisphere, eTIV)) %>%
  mutate(Hemisphere = case_when(
                ROI %in% c("Brainstem") ~ "Brainstem",
               Hemisphere == "L" ~ "Left Hemisphere",
               Hemisphere == "R" ~ "Right Hemisphere",
               TRUE ~ Hemisphere  # Keep any other values unchanged    TRUE ~ hemisphere
  )) %>%
mutate(Volume = Volume*100) %>%
arrange(ROI, age) %>%
mutate(p05 = mov_perc$p05*100, p50 = mov_perc$p50*100, p95 = mov_perc$p95*100) %>%

ggplot(aes(x=age, y=Volume, color=Hemisphere))+
geom_jitter(alpha=0.1, size =3, shape =19)+
geom_smooth(aes(x=age, y=p05), color='black', se=F, method='loess', span = 1, linewidth=1.5)+
geom_smooth(aes(x=age, y=p50), color='black', se=F, method='loess', span = 1, linewidth=1.5)+
geom_smooth(aes(x=age, y=p95), color='black', se=F, method='loess', span = 1, linewidth=1.5)+
geom_point(data = point, aes(x = age, y = Volume*100, color = Hemisphere, shape = Hemisphere),
            alpha = 0.8, size = 10) +

facet_wrap(~ROI, scale='free_y', ncol = 3)+
#labs(x="Age (year)", y="Percent Relative Volume", color="Hemisphere")+
theme_ipsum()+
scale_x_continuous(breaks = c(seq(0, 18, by = 3))) + 
ylab("Percent Relative Volume") + 
xlab("Age (year)")+
scale_y_continuous(breaks = breaks_four, labels = function(x) sprintf("%.2f", x)) +
#scale_color_manual(values=c("L"=okabe_ito_palette[1], "R"=okabe_ito_palette[2], "x"=okabe_ito_palette[]))+
#scale_colour_viridis_d(option='turbo')+
#scale_color_viridis_d(option='A',begin =0 , end = 0.75) + # Specify darker shades
scale_color_manual(values=c("Left Hemisphere"="blue", 
                            "Right Hemisphere"="red", 
                            "Brainstem"="#31a354"))+
theme(axis.title.x=element_text(size=28),
    axis.title.y=element_text(size=28),
    strip.text = element_text(size = 35, hjust = 0.5),
    axis.text.x = element_text(size=25),
    axis.text.y = element_text(size=25),
    panel.spacing = unit(0.1, "cm"),
    legend.position='bottom',
    legend.text = element_text(size=25),
    legend.spacing.x = unit(0.5, 'cm'),
    legend.title = element_blank(),
          panel.spacing.y = unit(1, "cm"),  # Increase vertical spacing between rows
     )
  
  
  
return(plot_data)
}

# Parameters
sex <- "Male"
age <- args[2] %>% as.numeric

volume_stat_file <- file.path(dest_dir, sub, "stats", "volume.stats.csv")

# Generate plot

plot <- final_ggplot(volume_stat_file, age, sex)


# Save to ping
jpg_path <- file.path(dest_dir, sub, "GrowthChart.jpg")
ggsave(filename = jpg_path, plot = plot, width = 18, height = 18)
cat("Data exported to", jpg_path, "successfully!\n")



