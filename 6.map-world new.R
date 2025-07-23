library(tidyverse)
library(maps)
library(ggsci)

# 读取数据
df <- read.csv("D:/科研工作/塑料片项目/代码整理/EVdata.csv")

# 去除列名中的空格
colnames(df) <- trimws(colnames(df))

# 查看列名，确保列名是 "Relative.abundance"
print(colnames(df))

# 加载世界地图数据
world <- map_data("world")

# 创建地图
p6 <- ggplot(data = df) + 
  
  # 绘制世界地图背景
  geom_polygon(data = world, aes(x = long, y = lat, group = group), 
               fill = "#D7D7D7", color = "#D7D7D7", size = 0.1) +
  
  # 绘制点，点的颜色和大小根据丰度变化
  geom_point(aes(x = Longitude, y = Latitude, fill = `Relative.abundance`, size = `Relative.abundance`),
             shape = 21, color = "black", stroke = 0.2) +
  
  # 设置颜色渐变，从浅色到深色
  scale_fill_gradient(low = "lightblue", high = "darkblue") +  # 可以调整颜色
  scale_size_continuous(range = c(1, 6)) +  # 设置点大小范围
  
  labs(x = "Longitude", y = "Latitude") +
  
  theme_minimal() +
  theme(legend.position = c(0.051, 0.5))  # 设置图例的位置

# 显示地图
p6

# 保存地图为PDF和PNG文件
ggsave(plot = p6, "samples_site_35.pdf", height = 96, width = 190, units = "mm")
ggsave(plot = p6, "samples_site_35.png", height = 96, width = 190, units = "mm")
