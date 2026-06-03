# Bootanimation HRCustom

O Android **não toca vídeo** no boot. Ele lê um `bootanimation.zip` com
frames PNG. Então o seu vídeo precisa virar frames.

## 1. Converter o vídeo em frames

```bash
# Descubra a resolução nativa do device:
#   Poco F5 (marble):  1080 x 2400
#   Poco F1 (beryllium): 1080 x 2246 (notch) -> use 1080x2160

mkdir -p part0
ffmpeg -i boot.mp4 -vf "scale=1080:2400,fps=30" part0/%04d.png
```

Dica: mantenha o vídeo curto (3-6s). Frames demais = zip grande e boot lento.

## 2. Criar o desc.txt

```
1080 2400 30
p 1 0 part0
p 0 0 part1
```

Formato da 1ª linha: `LARGURA ALTURA FPS`
Linhas de parte: `p <loop> <pause> <pasta>`
- `loop` = quantas vezes repete (`0` = repete até o boot terminar)
- `part0` toca 1x (intro), `part1` com loop `0` fica repetindo até o boot acabar.

## 3. Empacotar (SEM compressão!)

```bash
# -0 = store (obrigatório, senão o surfaceflinger não lê)
zip -r -0 bootanimation.zip desc.txt part0 part1
```

## 4. Colocar aqui

Salve o resultado como:

```
vendor/hrcustom/bootanimation/bootanimation.zip
```

O `Android.bp` deste diretório instala automaticamente em
`/system/media/bootanimation.zip` no próximo build.

## Verificar antes de buildar

```bash
unzip -l bootanimation.zip          # confere desc.txt + frames
unzip -v bootanimation.zip | grep desc.txt   # método deve ser "Stored", não "Defl"
```
