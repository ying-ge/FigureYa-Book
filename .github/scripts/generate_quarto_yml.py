import os
import yaml

def main(root='.'):
    chapters = []
    for folder in sorted(os.listdir(root)):
        folder_path = os.path.join(root, folder)
        if os.path.isdir(folder_path) and not folder.startswith('.'):
            qmd_files = [f for f in os.listdir(folder_path) if f.endswith('.qmd')]
            if "index.qmd" in qmd_files:
                chapters.append(f"{folder}/index.qmd")
            elif qmd_files:
                chapters.append(f"{folder}/{qmd_files[0]}")  # 用第一个 .qmd

    config = {
        "project": {"type": "book"},
        "book": {
            "title": "FigureYa Actions 电子书",
            "chapters": chapters
        },
        "format": {
            "html": {
                "toc": True,
                "search": True
            }
        }
    }
    with open('_quarto.yml', 'w', encoding='utf-8') as f:
        yaml.dump(config, f, sort_keys=False, allow_unicode=True)

if __name__ == '__main__':
    main('.')
