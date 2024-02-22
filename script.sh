#!/usr/bin/env bash

echo "Retaskd or Freecell"
read app

echo "Version name"
read apkname

cd ~/Documents/Flutter/{$app}/

flutter build apk --target-platform android-arm64

cd build/app/outputs/flutter-apk/
mv app-release.apk {$apkname}.apk


if [ $app = "Retaskd" ]
	gio move ~/Documents/Flutter/Retaskd/build/app/outputs/flutter-apk/{$apkname}.apk google-drive://b3939431@gmail.com/0AHHHQxca7H7zUk9PVA/1H7AP-eOrsYKVS91nHoiEyz2P9rhlUvI2/
else if [ $app = "Freecell" ]
	gio move ~/Documents/Flutter/Freecell/build/app/outputs/flutter-apk/{$apkname}.apk google-drive://b3939431@gmail.com/0AHHHQxca7H7zUk9PVA/189SDOcNdn7SybsILDxwzqZs0-QPDpOKr/
else 
	echo "Bruh"
end

echo "Done"
