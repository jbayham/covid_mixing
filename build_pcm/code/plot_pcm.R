#Code to plot matrices

lapply(c("tidyverse","gridExtra","scales","ggExtra"),
       require,character.only=T)

path_name <- "build_pcm/outputs/pcm_csv_summer/"
file.list <- dir(path_name,full.names = T)

#lab_text <- c("0-29","30-59","60+")
lab_text <- c("0-18","19-29","30-59","60+")

map(file.list,
    function(x){
      title_text <- str_sub(x,str_length(path_name)+1) %>%
        tools::file_path_sans_ext()
      
      temp_mat <- read_csv(x,col_names = F)
      
      pcm <- as_tibble(cbind(expand.grid(lab_text,lab_text),
                             unlist(temp_mat))) %>%
        rename_all(~c("Population","Individual","value")) %>%
        add_column(title_text)
      
      
      ggplot(pcm,aes(x=Individual,y=Population,fill=value,label=round(value, digits = 1))) +
        geom_tile() +
        geom_label(fill="white",alpha=.8,label.size = NA) +
        scale_fill_viridis_c(name="") +
        theme_minimal(base_size = 13) +
        coord_equal() +
        labs(#title = "Contact Minutes",
             title = title_text)
      
      
      ggplot2::ggsave(str_c("build_pcm/outputs/age3_location/",title_text,".png"),
             height = 4, width = 4.3,units = "in")
      
      margin_data<- pcm %>%
        group_by(Individual) %>%
        summarise(value=sum(value))
      
      ggplot(margin_data,aes(x=Individual,y=value)) +
        geom_col() +
        geom_text(aes(y=value+6,label=round(value,0))) +
        scale_y_continuous(expand = c(0, 0),limits = c(0,max(margin_data$value)*1.25)) +
        #ylim(0,max(margin_data$value)+10) +
        labs(x="",
             y="") +
        theme_classic() +
        theme(axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank())
      
      ggplot2::ggsave(str_c("build_pcm/outputs/age3_location/",title_text,"margin.png"),
                      height = 1, width = 3.2,units = "in")
      
    })


public <- as_tibble(cbind(expand.grid(lab_text,lab_text),
                          unlist(read_csv(str_c(path_name,"All Public.csv"),col_names = F)))) %>%
  rename_all(~c("Population","Individual","public")) 



map(str_subset(file.list,"All Public",negate = T),
    function(x){
      title_text <- str_sub(x,str_length(path_name)+1) %>%
        tools::file_path_sans_ext()
      
      temp_mat <- read_csv(x,col_names = F)
      
      pcm <- as_tibble(cbind(expand.grid(lab_text,lab_text),
                             unlist(temp_mat))) %>%
        rename_all(~c("Population","Individual","value")) %>% 
        inner_join(public,by=c("Population","Individual")) %>%
        mutate(value=value/public) %>%
        add_column(title_text)
      
      ggplot(pcm,aes(x=Individual,y=Population,fill=value,label=percent(value))) +
        geom_tile() +
        geom_label(fill="white",alpha=.8,label.size = NA) +
        scale_fill_viridis_c(name="",label=percent_format(1)) +
        theme_minimal(base_size = 13) +
        coord_equal() +
        labs(#title = "Contact Minutes",
             title = title_text)
      
      ggplot2::ggsave(str_c("build_pcm/outputs/age3_location/",title_text,"_percent.png"),
             height = 4, width = 4.3,units = "in")
      
    })
