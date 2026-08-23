#!/usr/bin/env python3
"""为 pub 缓存中所有插件的 android 构建脚本注入阿里云镜像（google() 之前）。
用法: python3 patch_pub_cache.py  （每次 flutter pub get / 加依赖后执行）"""
import glob

GROOVY_OLD = (
    '    repositories {\n'
    '        google()\n'
    '        mavenCentral()'
)
GROOVY_NEW = (
    '    repositories {\n'
    '        maven { url "https://maven.aliyun.com/repository/google" }\n'
    '        maven { url "https://maven.aliyun.com/repository/public" }\n'
    '        google()\n'
    '        mavenCentral()'
)
KTS_OLD = (
    '    repositories {\n'
    '        google()\n'
    '        mavenCentral()\n'
    '    }'
)
KTS_NEW = (
    '    repositories {\n'
    '        maven("https://maven.aliyun.com/repository/google")\n'
    '        maven("https://maven.aliyun.com/repository/public")\n'
    '        google()\n'
    '        mavenCentral()\n'
    '    }'
)

patched = skipped = 0
files = [f for f in glob.glob('/home/yzy_0/.pub-cache/hosted/*/*/android/build.gradle*')]
for f in files:
    s = open(f).read()
    if 'maven.aliyun.com' in s:
        skipped += 1
        continue
    is_kts = f.endswith('.kts')
    old, new = (KTS_OLD, KTS_NEW) if is_kts else (GROOVY_OLD, GROOVY_NEW)
    if old in s:
        open(f, 'w').write(s.replace(old, new))
        patched += 1
print(f'patched={patched} already_ok={skipped}')
