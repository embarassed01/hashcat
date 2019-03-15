DECLSPEC void camellia256_decrypt_xts_first (const u32 *ukey1, const u32 *ukey2, const u32 *in, u32 *out, u32 *S, u32 *T, u32 *ks);
DECLSPEC void camellia256_decrypt_xts_first (const u32 *ukey1, const u32 *ukey2, const u32 *in, u32 *out, u32 *S, u32 *T, u32 *ks)
{
  out[0] = in[0];
  out[1] = in[1];
  out[2] = in[2];
  out[3] = in[3];

  camellia256_set_key (ks, ukey2);
  camellia256_encrypt (ks, S, T);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  camellia256_set_key (ks, ukey1);
  camellia256_decrypt (ks, out, out);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];
}

DECLSPEC void camellia256_decrypt_xts_next (const u32 *in, u32 *out, u32 *T, u32 *ks);
DECLSPEC void camellia256_decrypt_xts_next (const u32 *in, u32 *out, u32 *T, u32 *ks)
{
  out[0] = in[0];
  out[1] = in[1];
  out[2] = in[2];
  out[3] = in[3];

  xts_mul2 (T, T);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  camellia256_decrypt (ks, out, out);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];
}

DECLSPEC void kuznyechik_decrypt_xts_first (const u32 *ukey1, const u32 *ukey2, const u32 *in, u32 *out, u32 *S, u32 *T, u32 *ks);
DECLSPEC void kuznyechik_decrypt_xts_first (const u32 *ukey1, const u32 *ukey2, const u32 *in, u32 *out, u32 *S, u32 *T, u32 *ks)
{
  out[0] = in[0];
  out[1] = in[1];
  out[2] = in[2];
  out[3] = in[3];

  kuznyechik_set_key (ks, ukey2);
  kuznyechik_encrypt (ks, S, T);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  kuznyechik_set_key (ks, ukey1);
  kuznyechik_decrypt (ks, out, out);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];
}

DECLSPEC void kuznyechik_decrypt_xts_next (const u32 *in, u32 *out, u32 *T, u32 *ks);
DECLSPEC void kuznyechik_decrypt_xts_next (const u32 *in, u32 *out, u32 *T, u32 *ks)
{
  out[0] = in[0];
  out[1] = in[1];
  out[2] = in[2];
  out[3] = in[3];

  xts_mul2 (T, T);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];

  kuznyechik_decrypt (ks, out, out);

  out[0] ^= T[0];
  out[1] ^= T[1];
  out[2] ^= T[2];
  out[3] ^= T[3];
}

// 512 bit

DECLSPEC int verify_header_camellia (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2);
DECLSPEC int verify_header_camellia (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2)
{
  u32 ks_camellia[68];

  u32 S[4] = { 0 };

  u32 T_camellia[4] = { 0 };

  u32 data[4];

  data[0] = data_buf[0];
  data[1] = data_buf[1];
  data[2] = data_buf[2];
  data[3] = data_buf[3];

  u32 tmp[4];

  camellia256_decrypt_xts_first (ukey1, ukey2, data, tmp, S, T_camellia, ks_camellia);

  if (tmp[0] != signature) return 0;

  const u32 crc32_save = swap32_S (~tmp[2]);

  // seek to byte 256

  for (int i = 4; i < 64 - 16; i += 4)
  {
    xts_mul2 (T_camellia, T_camellia);
  }

  // calculate crc32 from here

  u32 crc32 = ~0;

  for (int i = 64 - 16; i < 128 - 16; i += 4)
  {
    data[0] = data_buf[i + 0];
    data[1] = data_buf[i + 1];
    data[2] = data_buf[i + 2];
    data[3] = data_buf[i + 3];

    camellia256_decrypt_xts_next (data, tmp, T_camellia, ks_camellia);

    crc32 = round_crc32_4 (tmp[0], crc32);
    crc32 = round_crc32_4 (tmp[1], crc32);
    crc32 = round_crc32_4 (tmp[2], crc32);
    crc32 = round_crc32_4 (tmp[3], crc32);
  }

  if (crc32 != crc32_save) return 0;

  return 1;
}

DECLSPEC int verify_header_kuznyechik (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2);
DECLSPEC int verify_header_kuznyechik (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2)
{
  u32 ks_kuznyechik[40];

  u32 S[4] = { 0 };

  u32 T_kuznyechik[4] = { 0 };

  u32 data[4];

  data[0] = data_buf[0];
  data[1] = data_buf[1];
  data[2] = data_buf[2];
  data[3] = data_buf[3];

  u32 tmp[4];

  kuznyechik_decrypt_xts_first (ukey1, ukey2, data, tmp, S, T_kuznyechik, ks_kuznyechik);

  if (tmp[0] != signature) return 0;

  const u32 crc32_save = swap32_S (~tmp[2]);

  // seek to byte 256

  for (int i = 4; i < 64 - 16; i += 4)
  {
    xts_mul2 (T_kuznyechik, T_kuznyechik);
  }

  // calculate crc32 from here

  u32 crc32 = ~0;

  for (int i = 64 - 16; i < 128 - 16; i += 4)
  {
    data[0] = data_buf[i + 0];
    data[1] = data_buf[i + 1];
    data[2] = data_buf[i + 2];
    data[3] = data_buf[i + 3];

    kuznyechik_decrypt_xts_next (data, tmp, T_kuznyechik, ks_kuznyechik);

    crc32 = round_crc32_4 (tmp[0], crc32);
    crc32 = round_crc32_4 (tmp[1], crc32);
    crc32 = round_crc32_4 (tmp[2], crc32);
    crc32 = round_crc32_4 (tmp[3], crc32);
  }

  if (crc32 != crc32_save) return 0;

  return 1;
}

// 1024 bit

DECLSPEC int verify_header_camellia_kuznyechik (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4);
DECLSPEC int verify_header_camellia_kuznyechik (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4)
{
  u32 ks_camellia[68];
  u32 ks_kuznyechik[40];

  u32 S[4] = { 0 };

  u32 T_camellia[4]   = { 0 };
  u32 T_kuznyechik[4] = { 0 };

  u32 data[4];

  data[0] = data_buf[0];
  data[1] = data_buf[1];
  data[2] = data_buf[2];
  data[3] = data_buf[3];

  u32 tmp[4];

  camellia256_decrypt_xts_first (ukey2, ukey4, data, tmp, S, T_camellia,   ks_camellia);
  kuznyechik_decrypt_xts_first  (ukey1, ukey3, tmp,  tmp, S, T_kuznyechik, ks_kuznyechik);

  if (tmp[0] != signature) return 0;

  const u32 crc32_save = swap32_S (~tmp[2]);

  // seek to byte 256

  for (int i = 4; i < 64 - 16; i += 4)
  {
    xts_mul2 (T_camellia,   T_camellia);
    xts_mul2 (T_kuznyechik, T_kuznyechik);
  }

  // calculate crc32 from here

  u32 crc32 = ~0;

  for (int i = 64 - 16; i < 128 - 16; i += 4)
  {
    data[0] = data_buf[i + 0];
    data[1] = data_buf[i + 1];
    data[2] = data_buf[i + 2];
    data[3] = data_buf[i + 3];

    camellia256_decrypt_xts_next (data, tmp, T_camellia,   ks_camellia);
    kuznyechik_decrypt_xts_next  (tmp,  tmp, T_kuznyechik, ks_kuznyechik);

    crc32 = round_crc32_4 (tmp[0], crc32);
    crc32 = round_crc32_4 (tmp[1], crc32);
    crc32 = round_crc32_4 (tmp[2], crc32);
    crc32 = round_crc32_4 (tmp[3], crc32);
  }

  if (crc32 != crc32_save) return 0;

  return 1;
}

DECLSPEC int verify_header_camellia_serpent (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4);
DECLSPEC int verify_header_camellia_serpent (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4)
{
  u32 ks_camellia[68];
  u32 ks_serpent[140];

  u32 S[4] = { 0 };

  u32 T_camellia[4] = { 0 };
  u32 T_serpent[4]  = { 0 };

  u32 data[4];

  data[0] = data_buf[0];
  data[1] = data_buf[1];
  data[2] = data_buf[2];
  data[3] = data_buf[3];

  u32 tmp[4];

  camellia256_decrypt_xts_first (ukey2, ukey4, data, tmp, S, T_camellia, ks_camellia);
  serpent256_decrypt_xts_first  (ukey1, ukey3, tmp,  tmp, S, T_serpent,  ks_serpent);

  if (tmp[0] != signature) return 0;

  const u32 crc32_save = swap32_S (~tmp[2]);

  // seek to byte 256

  for (int i = 4; i < 64 - 16; i += 4)
  {
    xts_mul2 (T_camellia, T_camellia);
    xts_mul2 (T_serpent,  T_serpent);
  }

  // calculate crc32 from here

  u32 crc32 = ~0;

  for (int i = 64 - 16; i < 128 - 16; i += 4)
  {
    data[0] = data_buf[i + 0];
    data[1] = data_buf[i + 1];
    data[2] = data_buf[i + 2];
    data[3] = data_buf[i + 3];

    camellia256_decrypt_xts_next (data, tmp, T_camellia, ks_camellia);
    serpent256_decrypt_xts_next  (tmp,  tmp, T_serpent,  ks_serpent);

    crc32 = round_crc32_4 (tmp[0], crc32);
    crc32 = round_crc32_4 (tmp[1], crc32);
    crc32 = round_crc32_4 (tmp[2], crc32);
    crc32 = round_crc32_4 (tmp[3], crc32);
  }

  if (crc32 != crc32_save) return 0;

  return 1;
}

DECLSPEC int verify_header_kuznyechik_aes (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4);
DECLSPEC int verify_header_kuznyechik_aes (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4, SHM_TYPE u32 *s_te0, SHM_TYPE u32 *s_te1, SHM_TYPE u32 *s_te2, SHM_TYPE u32 *s_te3, SHM_TYPE u32 *s_te4, SHM_TYPE u32 *s_td0, SHM_TYPE u32 *s_td1, SHM_TYPE u32 *s_td2, SHM_TYPE u32 *s_td3, SHM_TYPE u32 *s_td4)
{
  u32 ks_kuznyechik[40];
  u32 ks_aes[60];

  u32 S[4] = { 0 };

  u32 T_kuznyechik[4] = { 0 };
  u32 T_aes[4]        = { 0 };

  u32 data[4];

  data[0] = data_buf[0];
  data[1] = data_buf[1];
  data[2] = data_buf[2];
  data[3] = data_buf[3];

  u32 tmp[4];

  kuznyechik_decrypt_xts_first (ukey2, ukey4, data, tmp, S, T_kuznyechik, ks_kuznyechik);
  aes256_decrypt_xts_first     (ukey1, ukey3, tmp,  tmp, S, T_aes,     ks_aes, s_te0, s_te1, s_te2, s_te3, s_te4, s_td0, s_td1, s_td2, s_td3, s_td4);

  if (tmp[0] != signature) return 0;

  const u32 crc32_save = swap32_S (~tmp[2]);

  // seek to byte 256

  for (int i = 4; i < 64 - 16; i += 4)
  {
    xts_mul2 (T_kuznyechik, T_kuznyechik);
    xts_mul2 (T_aes,        T_aes);
  }

  // calculate crc32 from here

  u32 crc32 = ~0;

  for (int i = 64 - 16; i < 128 - 16; i += 4)
  {
    data[0] = data_buf[i + 0];
    data[1] = data_buf[i + 1];
    data[2] = data_buf[i + 2];
    data[3] = data_buf[i + 3];

    kuznyechik_decrypt_xts_next (data, tmp, T_kuznyechik, ks_kuznyechik);
    aes256_decrypt_xts_next     (tmp,  tmp, T_aes,     ks_aes, s_td0, s_td1, s_td2, s_td3, s_td4);

    crc32 = round_crc32_4 (tmp[0], crc32);
    crc32 = round_crc32_4 (tmp[1], crc32);
    crc32 = round_crc32_4 (tmp[2], crc32);
    crc32 = round_crc32_4 (tmp[3], crc32);
  }

  if (crc32 != crc32_save) return 0;

  return 1;
}

DECLSPEC int verify_header_kuznyechik_twofish (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4);
DECLSPEC int verify_header_kuznyechik_twofish (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4)
{
  u32 ks_kuznyechik[40];

  u32 sk_twofish[4];
  u32 lk_twofish[40];

  u32 S[4] = { 0 };

  u32 T_kuznyechik[4] = { 0 };
  u32 T_twofish[4]    = { 0 };

  u32 data[4];

  data[0] = data_buf[0];
  data[1] = data_buf[1];
  data[2] = data_buf[2];
  data[3] = data_buf[3];

  u32 tmp[4];

  kuznyechik_decrypt_xts_first (ukey2, ukey4, data, tmp, S, T_kuznyechik, ks_kuznyechik);
  twofish256_decrypt_xts_first (ukey1, ukey3,  tmp, tmp, S, T_twofish, sk_twofish, lk_twofish);

  if (tmp[0] != signature) return 0;

  const u32 crc32_save = swap32_S (~tmp[2]);

  // seek to byte 256

  for (int i = 4; i < 64 - 16; i += 4)
  {
    xts_mul2 (T_kuznyechik, T_kuznyechik);
    xts_mul2 (T_twofish,    T_twofish);
  }

  // calculate crc32 from here

  u32 crc32 = ~0;

  for (int i = 64 - 16; i < 128 - 16; i += 4)
  {
    data[0] = data_buf[i + 0];
    data[1] = data_buf[i + 1];
    data[2] = data_buf[i + 2];
    data[3] = data_buf[i + 3];

    kuznyechik_decrypt_xts_next (data, tmp, T_kuznyechik, ks_kuznyechik);
    twofish256_decrypt_xts_next (tmp,  tmp, T_twofish, sk_twofish, lk_twofish);

    crc32 = round_crc32_4 (tmp[0], crc32);
    crc32 = round_crc32_4 (tmp[1], crc32);
    crc32 = round_crc32_4 (tmp[2], crc32);
    crc32 = round_crc32_4 (tmp[3], crc32);
  }

  if (crc32 != crc32_save) return 0;

  return 1;
}

// 1536 bit

DECLSPEC int verify_header_kuznyechik_serpent_camellia (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4, const u32 *ukey5, const u32 *ukey6);
DECLSPEC int verify_header_kuznyechik_serpent_camellia (__global const u32 *data_buf, const u32 signature, const u32 *ukey1, const u32 *ukey2, const u32 *ukey3, const u32 *ukey4, const u32 *ukey5, const u32 *ukey6)
{
  u32 ks_kuznyechik[40];
  u32 ks_serpent[140];
  u32 ks_camellia[68];

  u32 S[4] = { 0 };

  u32 T_kuznyechik[4] = { 0 };
  u32 T_serpent[4]    = { 0 };
  u32 T_camellia[4]   = { 0 };

  u32 data[4];

  data[0] = data_buf[0];
  data[1] = data_buf[1];
  data[2] = data_buf[2];
  data[3] = data_buf[3];

  u32 tmp[4];

  kuznyechik_decrypt_xts_first  (ukey3, ukey6, data, tmp, S, T_kuznyechik, ks_kuznyechik);
  serpent256_decrypt_xts_first  (ukey2, ukey5, tmp,  tmp, S, T_serpent,    ks_serpent);
  camellia256_decrypt_xts_first (ukey1, ukey4, tmp,  tmp, S, T_camellia,   ks_camellia);

  if (tmp[0] != signature) return 0;

  const u32 crc32_save = swap32_S (~tmp[2]);

  // seek to byte 256

  for (int i = 4; i < 64 - 16; i += 4)
  {
    xts_mul2 (T_kuznyechik, T_kuznyechik);
    xts_mul2 (T_serpent, T_serpent);
    xts_mul2 (T_camellia,     T_camellia);
  }

  // calculate crc32 from here

  u32 crc32 = ~0;

  for (int i = 64 - 16; i < 128 - 16; i += 4)
  {
    data[0] = data_buf[i + 0];
    data[1] = data_buf[i + 1];
    data[2] = data_buf[i + 2];
    data[3] = data_buf[i + 3];

    kuznyechik_decrypt_xts_next  (data, tmp, T_kuznyechik, ks_kuznyechik);
    serpent256_decrypt_xts_next  (tmp,  tmp, T_serpent,    ks_serpent);
    camellia256_decrypt_xts_next (tmp,  tmp, T_camellia,   ks_camellia);

    crc32 = round_crc32_4 (tmp[0], crc32);
    crc32 = round_crc32_4 (tmp[1], crc32);
    crc32 = round_crc32_4 (tmp[2], crc32);
    crc32 = round_crc32_4 (tmp[3], crc32);
  }

  if (crc32 != crc32_save) return 0;

  return 1;
}
