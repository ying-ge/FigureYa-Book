# --- 智能分析版 R 包收集和下载脚本 ---

# 加载所需库
library(dplyr)
library(purrr)
library(remotes)

# --- 配置 ---
SOURCE_REPO_PATH <- "source-repo"
TARGET_REPO_PATH <- "target-repo"
# ---

# 1. 查找所有依赖文件
dependency_files <- list.files(
  path = SOURCE_REPO_PATH,
  pattern = "install_dependencies.R",
  recursive = TRUE,
  full.names = TRUE
)

if (length(dependency_files) == 0) {
  stop("错误：在 '", SOURCE_REPO_PATH, "' 中没有找到 'install_dependencies.R' 文件。")
}

cat("找到以下依赖文件进行分析：\n")
print(dependency_files)

# 2. 智能分析文件，提取包列表
all_cran_packages <- c()
all_bioc_packages <- c()
all_github_packages <- c()

for (file_path in dependency_files) {
  cat("\n正在分析文件:", file_path, "\n")
  
  # 创建一个独立的环境来执行脚本，避免污染主环境
  script_env <- new.env()
  
  tryCatch({
    # 在独立环境中执行脚本
    source(file_path, local = script_env)
    
    # 检查并提取变量
    if (exists("cran_packages", envir = script_env)) {
      pkgs <- get("cran_packages", envir = script_env)
      cat("  > 找到 CRAN 包:", paste(pkgs, collapse = ", "), "\n")
      all_cran_packages <- c(all_cran_packages, pkgs)
    }
    if (exists("bioc_packages", envir = script_env)) {
      pkgs <- get("bioc_packages", envir = script_env)
      cat("  > 找到 Bioconductor 包:", paste(pkgs, collapse = ", "), "\n")
      all_bioc_packages <- c(all_bioc_packages, pkgs)
    }
    # 也可以在这里扩展，比如寻找 github_packages 变量
    
  }, error = function(e) {
    cat("  ! 分析时出错:", e$message, "\n")
  })
}

# 3. 清洗和汇总
# 过滤掉明显不是包名的项 (例如，包含 .bed, .bw 等)
is_valid_pkg_name <- function(name) {
  !grepl("\\.", name) || grepl("^[A-Za-z]", name)
}

unique_cran <- unique(all_cran_packages) %>% purrr::keep(is_valid_pkg_name)
unique_bioc <- unique(all_bioc_packages) %>% purrr::keep(is_valid_pkg_name)
# unique_github <- ...

cat("\n--- 汇总需要安装的包 (已清洗) ---\n")
cat("CRAN 包:\n")
print(unique_cran)
cat("\nBioconductor 包:\n")
print(unique_bioc)
cat("---------------------------------------\n\n")

# 4. 下载包的源码
dir.create(TARGET_REPO_PATH, showWarnings = FALSE)

# 合并 CRAN 和 Bioc 列表进行下载
packages_to_download <- unique(c(unique_cran, unique_bioc))

if (length(packages_to_download) > 0) {
  cat("开始下载源码包...\n")
  
  for (pkg in packages_to_download) {
    cat("尝试下载:", pkg, "\n")
    tryCatch({
      # remotes::download_version 会智能地从 CRAN 或 Bioconductor 寻找
      remotes::download_version(pkg, destdir = TARGET_REPO_PATH, type = "source")
      cat("  > 成功下载:", pkg, "\n")
    }, error = function(e) {
      cat("  ! 下载 '", pkg, "' 失败:", e$message, "\n")
    })
  }
}

cat("\n所有包下载完成。\n")
