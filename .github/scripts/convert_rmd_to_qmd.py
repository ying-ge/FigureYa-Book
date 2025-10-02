
import os

def convert_rmd_to_qmd(root):
    for folder in os.listdir(root):
        folder_path = os.path.join(root, folder)
        if os.path.isdir(folder_path):
            for file in os.listdir(folder_path):
                if file.endswith('.Rmd'):
                    rmd_path = os.path.join(folder_path, file)
                    qmd_path = os.path.join(folder_path, file[:-4] + '.qmd')
                    with open(rmd_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                    with open(qmd_path, 'w', encoding='utf-8') as f:
                        f.write(content)
                    print(f"{rmd_path} → {qmd_path}")

if __name__ == '__main__':
    convert_rmd_to_qmd('.')
