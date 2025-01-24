## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----echo=TRUE, include=TRUE,  warning=FALSE, message=FALSE-------------------

library(RegrCoeffsExplorer)
library(faraway)
library(dplyr)
library(ggplot2)
library(ggpubr)
library(gridExtra)
library(rlang)


## -----------------------------------------------------------------------------
# Get program choice of high school students data
hsb_data = faraway::hsb
head(hsb_data)

## -----------------------------------------------------------------------------
# Remove id column
hsb_data = subset(hsb_data, select=-c(id))

# Fit a glm model with binary family on all variables
glm_object=glm(I(prog == "academic") ~ gender + math + read + write + science 
               + socst + schtyp + ses + race,
              family=binomial(link="logit"), 
              data=hsb_data)

summary(glm_object)

## ----fig.height=6, fig.width=8------------------------------------------------
# Default side by side example for one variable
plot_OR(glm_object, hsb_data, var_name="math")$"SidebySide"

## ----fig.height=3, fig.width=8------------------------------------------------
# Default barplot example for one variable
plot_OR(glm_object, hsb_data, var_name="math")$"BarPlot"

## ----fig.height=3, fig.width=8------------------------------------------------
# Default boxplot example for one variable
plot_OR(glm_object, hsb_data, var_name="math")$"BoxPlot"

## -----------------------------------------------------------------------------
# Customize graph through layers and color parameter
or_plots = plot_OR(glm_object, hsb_data, var_name="math", 
                   color_filling=c("#CC6666", "#9999CC","#66CC99","#FF6600"))

## -----------------------------------------------------------------------------
# Get Barplot layers
or_plots$"BarPlot"$layers

## -----------------------------------------------------------------------------
# Get boxplot layers
or_plots$"BoxPlot"$layers

## ----fig.height=6, fig.width=8------------------------------------------------
# Change size of bars in the barplot
or_plots$"BarPlot"$layers[[1]]$geom_params$width = 1

# Change the boxplot type
or_plots$"BoxPlot"$layers[[1]]$geom_params$notch = FALSE

# Change size and transparency of points in the boxplot
or_plots$"BoxPlot"$layers[[2]]$aes_params$size = 0.5
or_plots$"BoxPlot"$layers[[2]]$aes_params$alpha = 0.1

# Plot both graphs together
ggarrange(or_plots$"BarPlot", or_plots$"BoxPlot", ncol=1, nrow=2, 
          common.legend=TRUE, legend="bottom")

## -----------------------------------------------------------------------------
customized_plots = function(or_plots) {
  # Change size of bars in the barplot
  or_plots$"BarPlot"$layers[[1]]$geom_params$width = 1
  
  # Change the boxplot type
  or_plots$"BoxPlot"$layers[[1]]$geom_params$notch = FALSE
  
  # Change size and transparency of points in the boxplot
  or_plots$"BoxPlot"$layers[[2]]$aes_params$size = 0.5
  or_plots$"BoxPlot"$layers[[2]]$aes_params$alpha = 0.1
  
  or_plots = ggarrange(or_plots$"BarPlot", or_plots$"BoxPlot", ncol=1, nrow=2, 
                       common.legend=TRUE, legend="bottom")

  return(or_plots)
}

## ----fig.height=10, fig.width=10----------------------------------------------
# Select continuous variables
continuous_vars = hsb_data %>%
  select_if(is.numeric)

# Create a list to store all plots
plot_list = list()

# Store side by side graphs for all numeric variables
for (name in colnames(continuous_vars)) {
  # Customize graph through layers and color parameter
  or_plots = plot_OR(glm_object, hsb_data, var_name=name, 
                     color_filling=c("#CC6666", "#9999CC","#66CC99","#FF6600"))
  
  # Plot both graphs together
  plot_list[[name]] = customized_plots(or_plots)
}

# Plot all graphs in one matrix
plot_grob = arrangeGrob(grobs=plot_list)
grid.arrange(plot_grob)

## ----fig.height=10, fig.width=10----------------------------------------------
# Select continuous variables
continuous_vars = hsb_data %>%
  select_if(is.numeric)

# Create a list to store all plots
plot_list = list()

# Define program names and target variable
prog_names = c("academic", "general", "vocation")
var_name = "science"

# Get Odds Ratio plots for Science variable for functions fitted for different programs 
for (name in prog_names) {
  # Fit a new GLM function for general and vocation programs
  if (name != "academic") {
    cur_glm_object = glm(I(prog == name) ~ gender + math + read + write + science 
                         + socst + schtyp + ses + race,
                         family=binomial(link="logit"), 
                         data=hsb_data)
    
  } else {
    cur_glm_object = glm_object
  }
  
  or_plots = plot_OR(cur_glm_object, hsb_data, var_name=var_name, 
                     color_filling=c("#CC6666", "#9999CC","#66CC99","#FF6600"))
  
  or_plots$"BarPlot" = or_plots$"BarPlot" + ggtitle(name)
  plot_list[[name]] = customized_plots(or_plots)
}

# Plot all graphs in one matrix
plot_grob = arrangeGrob(grobs=plot_list)
grid.arrange(plot_grob)

## ----fig.height=6, fig.width=8------------------------------------------------
# Boxplot for Science Scores factorized by high school programs
ggplot(hsb_data, aes(x=science, y=prog, fill=prog)) + 
  geom_boxplot() + theme(legend.position="none")

