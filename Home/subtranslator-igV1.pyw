import ctypes
ctypes.windll.kernel32.FreeConsole()

import tkinter as tk
from tkinter import filedialog, messagebox
from pathlib import Path
from deep_translator import GoogleTranslator
import re

def traduzir_legenda():
    # Selecionar o arquivo .srt
    filepath = filedialog.askopenfilename(
        title="Selecione o arquivo de legenda (.srt)",
        filetypes=[("Arquivos SRT", "*.srt")]
    )

    if not filepath:
        return  # Cancelado

    try:
        srt_path = Path(filepath)
        srt_content = srt_path.read_text(encoding="utf-8")

        # Quebrar o conteúdo em blocos
        blocks = re.split(r"\n\n+", srt_content.strip())

        # Separar índices, tempos e textos
        indexes, timestamps, subtitle_texts = [], [], []
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
        
        # Traduzir com deep_translator
        translated_texts = GoogleTranslator(source='en', target='pt').translate_batch(subtitle_texts)

        # Montar o novo conteúdo
        translated_blocks = [
            f"{idx}\n{time}\n{text}" for idx, time, text in zip(indexes, timestamps, translated_texts)
        ]
        translated_srt_content = "\n\n".join(translated_blocks)

        # Criar novo nome com -PT-BR
        new_filename = srt_path.with_name(srt_path.stem + "-PT-BR.srt")

        # Salvar novo arquivo
        new_filename.write_text(translated_srt_content, encoding="utf-8")

        messagebox.showinfo("Sucesso", f"Legenda traduzida salva como:\n{new_filename}")
    except Exception as e:
        messagebox.showerror("Erro", f"Ocorreu um erro:\n{e}")

# Criar janela tkinter
root = tk.Tk()
root.withdraw()  # Oculta a janela principal

# Executar função
traduzir_legenda()
