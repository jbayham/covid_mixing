#Code to plot matrices

lapply(c("tidyverse","gridExtra","scales","ggExtra"),
       require,character.only=T)

path_name <- "build_pcm/outputs/pcm_csv_individual_age/"
file.list <- dir(path_name,full.names = T)

#lab_text <- c("0-29","30-59","60+")
#lab_text <- c("0-18","19-29","30-59","60+")
exp_labs <- seq(1,81,1)
lab_text <- c(1,seq(10,81,10))

map(file.list,
    function(x){
      title_text <- str_sub(x,str_length(path_name)+1) %>%
        tools::file_path_sans_ext()
      
      temp_mat <- read_csv(x,col_names = F)
      
      pcm <- as_tibble(cbind(expand.grid(exp_labs,exp_labs),
                             unlist(temp_mat))) %>%
        rename_all(~c("Population","Individual","value")) %>%
        add_column(title_text)
      
      max_val <- quantile(pcm$value,p=.99)
      
      #show_col(viridis_pal(direction = -1)(1))
      
      
      p1 <- ggplot(pcm,aes(x=Individual,y=Population,fill=value)) +
        geom_tile() +
        #geom_label(fill="white",alpha=.8,label.size = NA) +
        scale_fill_viridis_c(name="",limits=c(0,max_val),na.value = "#FDE725FF") +
        #scale_x_discrete(breaks=lab_text) +
        scale_x_continuous(expand = c(0, 0)) +
        scale_y_continuous(expand = c(0, 0)) +
        #scale_y_discrete(breaks=lab_text) +
        theme_minimal(base_size = 13) +
        coord_equal() +
        theme(plot.margin = margin(.1, 0, 0, 0, "cm"))

      

      margin_data<- pcm %>%
        group_by(Individual) %>%
        summarise(value=sum(value))
      
      p2 <- ggplot(margin_data,aes(x=Individual,y=value)) +
        geom_col(aes(fill=value),width = 1,show.legend = F) +
        scale_fill_viridis_c() +
        #geom_text(aes(y=value+6,label=round(value,0))) +
        scale_y_continuous(expand = c(0, 0)) +
        scale_x_discrete(expand = c(0, 0)) +
        #ylim(0,max(margin_data$value)+10) +
        labs(x="",
             y="") +
        theme_classic() +
        theme(axis.title.x = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks.x = element_blank(),
              plot.margin = margin(0, 0, 0, 0, "cm"))
      
      
      top <- cowplot::plot_grid(NULL,p2,NULL,ncol = 3,rel_widths = c(.35,4,1.85))
      
      cowplot::plot_grid(top,p1,nrow = 2,axis = "l",align = "v",rel_heights = c(.35,1))
      
      ggsave(str_c("build_pcm/outputs/age81_location/",title_text,"_combined.png"))
           

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
