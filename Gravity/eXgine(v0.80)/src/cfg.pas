{
  Включение статической линковки eXgine с exe
  При объявлении EX_STATIC, приложение компилируется в один exe файл
  Путь к папке с исходным кодом eXgine рекомендуется указывать через
  "Search path" в настройках проекта.
  По умолчанию директива EX_STATIC отключена (используется eXgine.dll)

  При перекомпиляции eXgine.dll необходимо включить объявление EX_INIT.

  Для проигрывания Ogg Vorbis файлов, в директории с exe должны лежать модули:
    ogg.dll, vorbis.dll, vorbisfile.dll (http://xiph.org/)
    и соответствующая директива NO_OGG не должна быть объявлена
}
//  {$DEFINE EX_STATIC} // ни на что не влияет при компиляции eXgine.dll :)
//  {$DEFINE EX_INIT}   // Ручная инициализация eXgine (обязательна при компиляции eXgine.dll)

//  {$DEFINE NO_LOG}  // не вести лог файл (log.txt)
{$IFDEF EX_STATIC}
//  {$DEFINE NO_TEX}  // без ITexture (также отключит шрифты...)
//  {$DEFINE NO_VFP}  // IShader
//  {$DEFINE NO_VBO}  // IVBuffer
//  {$DEFINE NO_SND}  // ISound
//  {$DEFINE NO_INP}  // IInput
//  {$DEFINE NO_NET}  // INetwork
//  {$DEFINE NO_VEC}  // IVector

  {$IFNDEF NO_TEX}
  //  {$DEFINE NO_TGA}  // отключить поддержку tga
  //  {$DEFINE NO_BJG}  // bmp, jpg и gif файлов - текстур
  //  {$DEFINE NO_FBO}  // рендеринга в текстуру с использованием FBO
  //  {$DEFINE NO_FNT}  // Не создавать Default шрифт
  {$ENDIF}

  {$IFNDEF NO_SND}
  //  {$DEFINE NO_MCI}  // без проигрывания мультимедийных файлов (wav, mp3, wma, avi, asf и т.п.)
  //  {$DEFINE NO_OGG}  // отключает поддержку ogg модуля
  {$ENDIF}

  {$IFNDEF NO_INP}
  //  {$DEFINE NO_JOY}  // отключить поддержку джойстика
  {$ENDIF}
{$ENDIF}
