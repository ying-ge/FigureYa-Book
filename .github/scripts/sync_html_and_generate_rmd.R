# 自动同步 FigureYa HTML，分类生成章节Rmd，并可用于 Bookdown 渲染
library(fs)
library(yaml)
library(glue)
library(htmltools)

# 1. 读取分类规则
# 假设你有一个 chapters.yml 分类文件，结构如下：
# basic:
#   - FigureYa101PCA
#   - FigureYa12box
# bioinfo:
#   - FigureYa13GSEA_Java_update
#   - FigureYa61GSVA
chapters <- yaml::read_yaml("chapters.yml")

# 2. 为每一章创建目录，搜集html，生成Rmd
rmd_files <- c("index.Rmd")
chapter_titles <- c(
  basic = "基础可视化与统计入门",
  bioinfo = "生物信息学分析",
  immuno = "免疫与肿瘤微环境",
  ml = "机器学习与预测建模",
  panomics = "泛癌与多组学整合分析",
  appendix = "附录"
)
for (chapter in names(chapters)) {
  dir_create(chapter)
  html_files <- character()
  for (figdir in chapters[[chapter]]) {
    # 搜索每个FigureYa子目录下的html
    htmls <- dir_ls(path = file.path("FigureYa-source", figdir), glob = "*.html", recurse = FALSE)
    if (length(htmls) > 0) {
      file_copy(htmls, chapter, overwrite = TRUE)
      html_files <- c(html_files, file.path(chapter, path_file(htmls)))
    }
  }
  # 生成本章Rmd
  rmd_file <- glue("{chapter}.Rmd")
  rmd_files <- c(rmd_files, rmd_file)
  cat(glue("# {chapter_titles[[chapter]] %||% chapter}\n\n"), file = rmd_file)
  for (f in html_files) {
    cat(glue('```{{r, results="asis", echo=FALSE}}\nhtmltools::includeHTML("{f}")\n```\n\n'), file = rmd_file, append = TRUE)
  }
}

# 3. 生成_bookdown.yml
bookdown_yml <- c(
  "book_filename: \"FigureYaBook\"",
  "language:",
  "  ui:",
  "    chapter_name: \"第 \"",
  "rmd_files:",
  paste0("  - \"", rmd_files, "\"")
)
writeLines(bookdown_yml, "_bookdown.yml")
