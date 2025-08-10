from pathlib import Path

# Caminho para o arquivo de legenda SRT
srt_path = Path(r"C:\Users\ericd\Downloads\Osiris (2025) [720p] [WEBRip] [YTS.MX]\Osiris.2025.720p.WEBRip.x264.AAC-[YTS.MX].srt")

# Ler o conteúdo do arquivo
srt_content = srt_path.read_text(encoding="utf-8")

# Exibir os primeiros 20 blocos da legenda para começar a tradução
import re

# Quebrar o arquivo em blocos de legendas
blocks = re.split(r"\n\n+", srt_content.strip())

# Mostrar apenas os primeiros blocos para visualização e tradução
blocks[:20]

from deep_translator import GoogleTranslator

# Extrair apenas o texto das legendas para tradução
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

# Traduzir todos os textos de legenda para o português brasileiro
translated_texts = GoogleTranslator(source='en', target='pt').translate_batch(subtitle_texts)

# Reconstruir o conteúdo SRT com as traduções
translated_blocks = [
    f"{idx}\n{time}\n{text}" for idx, time, text in zip(indexes, timestamps, translated_texts)
]

translated_srt_content = "\n\n".join(translated_blocks)

# Salvar legenda traduzida
translated_srt_path = r"C:\Users\ericd\Downloads\Osiris (2025) [720p] [WEBRip] [YTS.MX]\Osiris.2025.720p.WEBRip.x264.AAC-[YTS.MX]-PT-BR.srt"
Path(translated_srt_path).write_text(translated_srt_content, encoding="utf-8")

translated_srt_path
