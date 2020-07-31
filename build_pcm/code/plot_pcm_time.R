

lapply(c("tidyverse","gridExtra","gganimate"),
       require,character.only=T)
conflict_prefer("View", "gganimate")

file.list <- dir("build_pcm/outputs/time_pcm_csv/",full.names = T)

all_pcms <- map_dfr(file.list,
    function(x){
      title_text <- str_sub(x,32) %>%
        tools::file_path_sans_ext()
      
      #temp_mat <- read_csv(x,col_names = F)
      temp_mat <- data.table::fread(x,header = F)
      
      lab_text <- c("0-29","30-59","60+")
      
      pcm <- as_tibble(cbind(expand.grid(lab_text,lab_text),
                             unlist(temp_mat))) %>%
        rename_all(~c("Population","Individual","value")) %>%
        add_column(title_text)
      

    })


ggplot(all_pcms,aes(x=Individual,y=Population,fill=value)) +
  geom_tile() +
  scale_fill_viridis_c(name="",limits=c(0,.01),na.value = "yellow") +
  theme_minimal() +
  coord_equal() +
  transition_states(title_text) +
  ggtitle("Contact Minutes",
          subtitle = 'Frame {frame} of {nframes}')

ggsave(str_c("build_pcm/outputs/age3_location/",title_text,".png"))