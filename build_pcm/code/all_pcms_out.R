

lapply(c("tidyverse","gridExtra"),
       require,character.only=T)

path_name <- "build_pcm/outputs/pcm_csv_summer/"
file.list <- dir(path_name,full.names = T)

#lab_text <- c("0-29","30-59","60+")
lab_text <- c("0-18","19-29","30-59","60+")

all_pcms <- map_dfr(file.list,
    function(x){
      title_text <- str_sub(x,str_length(path_name)+1) %>%
        tools::file_path_sans_ext()
      
      temp_mat <- read_csv(x,col_names = F) %>%
        rename_all(~lab_text) %>%
        add_column(location=title_text,population_age=lab_text,.before = 1)
      
      
    })

all_pcms %>%
  pivot_longer(cols = -c(location,population_age),names_to = "age") %>%
  group_by(location) %>%
  summarize(calc=sum(value)) %>%
  mutate(frac=calc/calc[1])

#save(all_pcms,file="build_pcm/outputs/all_pcms.Rdata")
write_csv(all_pcms,"build_pcm/outputs/all_pcms.csv")
