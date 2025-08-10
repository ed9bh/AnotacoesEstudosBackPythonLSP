import re
from pathlib import Path
from tkinter import Tk, filedialog, messagebox
from deep_translator import GoogleTranslator

def traduzir_legenda():
    # Inicializa janela do Tkinter oculta
    root = Tk()
    root.withdraw()

    # Selecionar arquivo SRT
    srt_file = filedialog.askopenfilename(
        title="Selecione um arquivo SRT",
        filetypes=[("Arquivos SRT", "*.srt")]
    )
    
    if not srt_file:
        messagebox.showinfo("Cancelado", "Nenhum arquivo selecionado.")
        return

    srt_path = Path(srt_file)

    try:
        # Ler conteúdo
        srt_content = srt_path.read_text(encoding="utf-8")

        # Quebrar em blocos
        blocks = re.split(r"\n\n+", srt_content.strip())

        # Extrair partes para tradução
        subtitle_texts = []
        timestamps = []
        indexes = []

        for block in blocks:
            lines = block.strip().split('\n')
            if len(lines) >= 3:
                indexes.append(lines[0])
                timestamps.append(lines[1])
                subtitle_texts.append(" ".join(lines[2:]))
            elif len(lines) == 2:
                indexes.append(lines[0])
                timestamps.append(lines[1])
                subtitle_texts.append("")
            else:
                continue

        # Traduzir
        translated_texts = GoogleTranslator(source='en', target='pt').translate_batch(subtitle_texts)

        # Recriar blocos
        translated_blocks = [
            f"{idx}\n{time}\n{text}" for idx, time, text in zip(indexes, timestamps, translated_texts)
        ]
        translated_srt_content = "\n\n".join(translated_blocks)

        # Criar novo caminho com "PT-BR"
        new_name = srt_path.stem + "-PT-BR" + srt_path.suffix
        new_path = srt_path.parent / new_name

        # Salvar
        new_path.write_text(translated_srt_content, encoding="utf-8")

        messagebox.showinfo("Sucesso", f"Arquivo salvo como:\n{new_path}")

    except Exception as e:
        messagebox.showerror("Erro", str(e))

if __name__ == "__main__":
    traduzir_legenda()
