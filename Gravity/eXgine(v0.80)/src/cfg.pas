{
  ��������� ����������� �������� eXgine � exe
  ��� ���������� EX_STATIC, ���������� ������������� � ���� exe ����
  ���� � ����� � �������� ����� eXgine ������������� ��������� �����
  "Search path" � ���������� �������.
  �� ��������� ��������� EX_STATIC ��������� (������������ eXgine.dll)

  ��� �������������� eXgine.dll ���������� �������� ���������� EX_INIT.

  ��� ������������ Ogg Vorbis ������, � ���������� � exe ������ ������ ������:
    ogg.dll, vorbis.dll, vorbisfile.dll (http://xiph.org/)
    � ��������������� ��������� NO_OGG �� ������ ���� ���������
}
//  {$DEFINE EX_STATIC} // �� �� ��� �� ������ ��� ���������� eXgine.dll :)
//  {$DEFINE EX_INIT}   // ������ ������������� eXgine (����������� ��� ���������� eXgine.dll)

//  {$DEFINE NO_LOG}  // �� ����� ��� ���� (log.txt)
{$IFDEF EX_STATIC}
//  {$DEFINE NO_TEX}  // ��� ITexture (����� �������� ������...)
//  {$DEFINE NO_VFP}  // IShader
//  {$DEFINE NO_VBO}  // IVBuffer
//  {$DEFINE NO_SND}  // ISound
//  {$DEFINE NO_INP}  // IInput
//  {$DEFINE NO_NET}  // INetwork
//  {$DEFINE NO_VEC}  // IVector

  {$IFNDEF NO_TEX}
  //  {$DEFINE NO_TGA}  // ��������� ��������� tga
  //  {$DEFINE NO_BJG}  // bmp, jpg � gif ������ - �������
  //  {$DEFINE NO_FBO}  // ���������� � �������� � �������������� FBO
  //  {$DEFINE NO_FNT}  // �� ��������� Default �����
  {$ENDIF}

  {$IFNDEF NO_SND}
  //  {$DEFINE NO_MCI}  // ��� ������������ �������������� ������ (wav, mp3, wma, avi, asf � �.�.)
  //  {$DEFINE NO_OGG}  // ��������� ��������� ogg ������
  {$ENDIF}

  {$IFNDEF NO_INP}
  //  {$DEFINE NO_JOY}  // ��������� ��������� ���������
  {$ENDIF}
{$ENDIF}
