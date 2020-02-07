# RK2206 mbed TLS开发指南

文件标识：RK-KF-YF-327

发布版本：V1.0.0

日期：2020-02-20

文件密级：□绝密   □秘密   □内部资料   ■公开

------

**免责声明**

本文档按“现状”提供，福州瑞芯微电子股份有限公司（“本公司”，下同）不对本文档的任何陈述、信息和内容的准确性、可靠性、完整性、适销性、特定目的性和非侵权性提供任何明示或暗示的声明或保证。本文档仅作为使用指导的参考。

由于产品版本升级或其他原因，本文档将可能在未经任何通知的情况下，不定期进行更新或修改。

商标声明

“Rockchip”、“瑞芯微”、“瑞芯”均为本公司的注册商标，归本公司所有。

本文档可能提及的其他所有注册商标或商标，由其各自拥有者所有。

版权所有 © 2020 福州瑞芯微电子股份有限公司

超越合理使用范畴，非经本公司书面许可，任何单位和个人不得擅自摘抄、复制本文档内容的部分或全部，并不得以任何形式传播。

福州瑞芯微电子股份有限公司

Fuzhou Rockchip Electronics Co., Ltd.

地址：     福建省福州市铜盘路软件园A区18号

网址：     www.rock-chips.com

客户服务电话： +86-4007-700-590

客户服务传真： +86-591-83951833

客户服务邮箱： fae@rock-chips.com

------

## **前言**

**概述**

本文旨在介绍mbed TLS部分算法使用示例，详情请参考官网[mbed TLS](https://tls.mbed.org)。

**产品版本**

| **芯片名称** | **内核版本**     |
| ------------ | ---------------- |
| RK2206       | FreeRTOS V10.0.1 |

**读者对象**

本文档（本指南）主要适用于以下工程师：

1. 技术支持工程师
2. 软件开发工程师

**修订记录**

| **日期**   | **版本** | **作者** | **修改说明**           |
| ---------- | -------- | --------  | ---------------------- |
| 2020-02-20 | V1.0.0   | Conway Chen | 初始版本               |

## **目录**

[TOC]

### **1. mbed TLS介绍**

mbed TLS使开发人员可以非常轻松地在（嵌入式产品中加入加密和 SSL/TLS 功能。它提供了具有直观的 API和可读源代码的SSL库。该工具即开即用，可以在大部分系统上直接构建它，也可以手动选择和配置各项功能。mbed TLS库提供了一组可单独使用和编译的加密组件，还可以使用单个配置头文件加入或排除这些组件。从功能角度来看，该mbedtls分为三个主要部分：SSL/TLS 协议实施，一个加密库，一个 X.509 证书处理库

- 代码位置

```
src/components/net/mbedtls
```

- 引用头文件

```
src/components/net/mbedtls/include/mbedtls 目录下相关头文件，根据需要include
```

- 编译

```
make distclean
make menuconfig
路径：
(top menu) → Components Config → NetWork →  使能mbed TLS
make build -j32
```

### **2. mbed TLS使用例程**

由于mbed TLS算法丰富，本文档只提供部分示例，供用户参考，算法更多具体使用请访问mbed TLS官网。

官网地址: [mbed TLS](https://tls.mbed.org)
官方源码地址：[mbed TLS source](https://github.com/ARMmbed/mbedtls)

#### **2.1 base64**

```c
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include "mbedtls/base64.h"
#include "mbedtls/platform.h"

static uint8_t msg[] =
{
    0x14, 0xfb, 0x9c, 0x03, 0xd9, 0x7e
};

void dump_buf(char *info, uint8_t *buf, uint32_t len)
{
    mbedtls_printf("%s", info);
    for(uint32_t i = 0; i < len; i++) {
        mbedtls_printf("%02x ", msg[i]);
    }
    mbedtls_printf("\n");
}

int main(void)
{
    size_t len;
    uint8_t rst[512];

    len = sizeof(msg);
    dump_buf("\n  base64 message: ", msg, len);

    mbedtls_base64_encode(rst, sizeof(rst), &len, msg, len);
    mbedtls_printf("  base64 encode : %s\n", rst);

    mbedtls_base64_decode(rst, sizeof(rst), &len, rst, len);
    dump_buf("  base64 decode : ", rst, len);
    printf("\n");

    return 0;
}
```

用例输出

```
base64 message: 14 fb 9c 03 d9 7e
base64 encode : FPucA9l+
base64 decode : 14 fb 9c 03 d9 7e
```

#### **2.2 hash**

mbedtls_config.h

```c
#ifndef MBEDTLS_CONFIG_H
#define MBEDTLS_CONFIG_H

/* System support */
#define MBEDTLS_PLATFORM_C
#define MBEDTLS_PLATFORM_MEMORY
#define MBEDTLS_MEMORY_BUFFER_ALLOC_C
#define MBEDTLS_PLATFORM_NO_STD_FUNCTIONS
#define MBEDTLS_PLATFORM_EXIT_ALT
#define MBEDTLS_NO_PLATFORM_ENTROPY
#define MBEDTLS_NO_DEFAULT_ENTROPY_SOURCES
#define MBEDTLS_PLATFORM_PRINTF_ALT

/* mbed TLS modules */
#define MBEDTLS_MD_C
#define MBEDTLS_SHA256_C

#include "mbedtls/check_config.h"

#endif /* MBEDTLS_CONFIG_H */
```

main.c

```c
/*
 * @file
 * @brief chapter hash samples.
 * @note  测试向量来自 https://csrc.nist.gov/CSRC/media/Projects/Cryptographic-Standards-and-Guidelines/documents/examples/SHA256.pdf
*/
#include <zephyr.h>

#include <stdio.h>
#include <string.h>

#include "mbedtls/md.h"
#include "mbedtls/platform.h"

static void dump_buf(char *info, uint8_t *buf, uint32_t len)
{
    mbedtls_printf("%s", info);
    for (int i = 0; i < len; i++) {
        mbedtls_printf("%s%02X%s", i % 16 == 0 ? "\n\t":" ",
                        buf[i], i == len - 1 ? "\n":"");
    }
    mbedtls_printf("\n");
}

int main(void)
{
    uint8_t digest[32];
    char *msg = "abc";

    mbedtls_md_context_t ctx;
    const mbedtls_md_info_t *info;

    mbedtls_platform_set_printf(printf);

    mbedtls_md_init(&ctx);
    info = mbedtls_md_info_from_type(MBEDTLS_MD_SHA256);

    mbedtls_md_setup(&ctx, info, 0);
    mbedtls_printf("\n  md info setup, name: %s, digest size: %d\n",
                   mbedtls_md_get_name(info), mbedtls_md_get_size(info));

    mbedtls_md_starts(&ctx);
    mbedtls_md_update(&ctx, msg, strlen(msg));
    mbedtls_md_finish(&ctx, digest);

    dump_buf("\n  md sha-256 digest:", digest, sizeof(digest));
    mbedtls_md_free(&ctx);
    return 0;
}
```

用例输出

```
md info setup, name: SHA256, digest size: 32

md sha-256 digest:
    BA 78 16 BF 8F 01 CF EA 41 41 40 DE 5D AE 22 23
    B0 03 61 A3 96 17 7A 9C B4 10 FF 61 F2 00 15 AD
```

#### **2.3 aes**

mbedtls_config.h

```c
#ifndef MBEDTLS_CONFIG_H
#define MBEDTLS_CONFIG_H

/* System support */
#define MBEDTLS_PLATFORM_C
#define MBEDTLS_PLATFORM_MEMORY
#define MBEDTLS_MEMORY_BUFFER_ALLOC_C
#define MBEDTLS_PLATFORM_NO_STD_FUNCTIONS
#define MBEDTLS_PLATFORM_EXIT_ALT
#define MBEDTLS_NO_PLATFORM_ENTROPY
#define MBEDTLS_NO_DEFAULT_ENTROPY_SOURCES
#define MBEDTLS_PLATFORM_PRINTF_ALT

/* mbed TLS modules */
#define MBEDTLS_AES_C
#define MBEDTLS_CIPHER_C
#define MBEDTLS_CIPHER_MODE_CBC
#define MBEDTLS_CIPHER_MODE_CTR
#define MBEDTLS_CIPHER_MODE_WITH_PADDING
#define MBEDTLS_CIPHER_PADDING_PKCS7

#define MBEDTLS_AES_ROM_TABLES

#include "mbedtls/check_config.h"

#endif /* MBEDTLS_CONFIG_H */

```

main.c

```c
#include <string.h>
#include <stdio.h>

#include "mbedtls/cipher.h"
#include "mbedtls/platform.h"

/*
    # padding with pkcs7 AES_128_CBC Encrypt
    ptx = "CBC has been the most commonly used mode of operation."
    key = 06a9214036b8a15b512e03d534120006
    iv  = 3dafba429d9eb430b422da802c9fac41
    ctx = 4DDF9012D7B3898745A1ED9860EB0FA2
          FD2BBD80D27190D72A2F240C8F372A27
          63746296DDC2BFCE7C252B6CD7DD4BA8
          577E096DBD8024C8B4C5A1160CA2D3F9
*/
char *ptx = "CBC has been the most commonly used mode of operation.";
uint8_t key[16] =
{
    0x06, 0xa9, 0x21, 0x40, 0x36, 0xb8, 0xa1, 0x5b,
    0x51, 0x2e, 0x03, 0xd5, 0x34, 0x12, 0x00, 0x06
};

uint8_t iv[16] =
{
    0x3d, 0xaf, 0xba, 0x42, 0x9d, 0x9e, 0xb4, 0x30,
    0xb4, 0x22, 0xda, 0x80, 0x2c, 0x9f, 0xac, 0x41
};

static void dump_buf(char *info, uint8_t *buf, uint32_t len)
{
    mbedtls_printf("%s", info);
    for (int i = 0; i < len; i++) {
        mbedtls_printf("%s%02X%s", i % 16 == 0 ? "\n\t":" ",
                        buf[i], i == len - 1 ? "\n":"");
    }
    mbedtls_printf("\n");
}

void cipher(int type)
{
    size_t len;
    int olen = 0;
    uint8_t buf[64];

    mbedtls_cipher_context_t ctx;
    const mbedtls_cipher_info_t *info;

    mbedtls_platform_set_printf(printf);

    mbedtls_cipher_init(&ctx);
    info = mbedtls_cipher_info_from_type(type);

    mbedtls_cipher_setup(&ctx, info);
    mbedtls_printf("\n  cipher info setup, name: %s, block size: %d\n",
                        mbedtls_cipher_get_name(&ctx),
                        mbedtls_cipher_get_block_size(&ctx));

    mbedtls_cipher_setkey(&ctx, key, sizeof(key)*8, MBEDTLS_ENCRYPT);
    mbedtls_cipher_set_iv(&ctx, iv, sizeof(iv));
    mbedtls_cipher_update(&ctx, ptx, strlen(ptx), buf, &len);
    olen += len;

    mbedtls_cipher_finish(&ctx, buf + len, &len);
    olen += len;

    dump_buf("\n  cipher aes encrypt:", buf, olen);

    mbedtls_cipher_free(&ctx);
}

int main(void)
{
    cipher(MBEDTLS_CIPHER_AES_128_CBC);
    cipher(MBEDTLS_CIPHER_AES_128_CTR);
    return 0;
}

```

用例输出

```
cipher info setup, name: AES-128-CBC, block size: 16

cipher aes encrypt:
    4D DF 90 12 D7 B3 89 87 45 A1 ED 98 60 EB 0F A2
    FD 2B BD 80 D2 71 90 D7 2A 2F 24 0C 8F 37 2A 27
    63 74 62 96 DD C2 BF CE 7C 25 2B 6C D7 DD 4B A8
    57 7E 09 6D BD 80 24 C8 B4 C5 A1 16 0C A2 D3 F9

cipher info setup, name: AES-128-CTR, block size: 16

cipher aes encrypt:
    C4 1A 1D B1 56 C0 9B 59 E8 25 D9 5B 72 FD 97 BE
    F7 06 BA C1 B8 4F F5 4E 72 88 2D 17 0B DB 53 0A
    9B 0A FD 86 41 65 73 06 6B C1 F0 52 18 FC 1D 57
    9D F4 81 F7 08 CB
```

#### **2.4 rsa**

mbedtls_config.h

```c
#ifndef MBEDTLS_CONFIG_H
#define MBEDTLS_CONFIG_H

/* System support */
#define MBEDTLS_PLATFORM_C
#define MBEDTLS_PLATFORM_MEMORY
#define MBEDTLS_MEMORY_BUFFER_ALLOC_C
#define MBEDTLS_PLATFORM_NO_STD_FUNCTIONS
#define MBEDTLS_PLATFORM_EXIT_ALT
#define MBEDTLS_NO_PLATFORM_ENTROPY
#define MBEDTLS_NO_DEFAULT_ENTROPY_SOURCES
#define MBEDTLS_PLATFORM_PRINTF_ALT
#define MBEDTLS_PLATFORM_SNPRINTF_ALT

/* mbed TLS modules */
#define MBEDTLS_AES_C
#define MBEDTLS_SHA256_C
#define MBEDTLS_ENTROPY_C
#define MBEDTLS_CTR_DRBG_C
#define MBEDTLS_BIGNUM_C
#define MBEDTLS_GENPRIME
#define MBEDTLS_MD_C
#define MBEDTLS_OID_C
#define MBEDTLS_RSA_C
#define MBEDTLS_PKCS1_V21

#define MBEDTLS_AES_ROM_TABLES

#include "mbedtls/check_config.h"

#endif /* MBEDTLS_CONFIG_H */

```

main.c

```c
#include <zephyr.h>

#include <stdio.h>
#include <string.h>

#include "mbedtls/rsa.h"
#include "mbedtls/entropy.h"
#include "mbedtls/ctr_drbg.h"
#include "mbedtls/platform.h"

#define assert_exit(cond, ret) \
    do { if (!(cond)) { \
        printf("  !. assert: failed [line: %d, error: -0x%04X]\n", __LINE__, -ret); \
        goto cleanup; \
    } } while (0)

static void dump_buf(char *info, uint8_t *buf, uint32_t len)
{
    mbedtls_printf("%s", info);
    for (int i = 0; i < len; i++) {
        mbedtls_printf("%s%02X%s", i % 16 == 0 ? "\n     ":" ",
                        buf[i], i == len - 1 ? "\n":"");
    }
}

static int entropy_source(void *data, uint8_t *output, size_t len, size_t *olen)
{
    uint32_t seed;

    seed = sys_rand32_get();
    if (len > sizeof(seed)) {
        len = sizeof(seed);
    }

    memcpy(output, &seed, len);

    *olen = len;
    return 0;
}

static void dump_rsa_key(mbedtls_rsa_context *ctx)
{
    size_t olen;
    uint8_t buf[516];
    mbedtls_printf("\n  +++++++++++++++++ rsa keypair +++++++++++++++++\n\n");
    mbedtls_mpi_write_string(&ctx->N , 16, buf, sizeof(buf), &olen);
    mbedtls_printf("N: %s\n", buf);

    mbedtls_mpi_write_string(&ctx->E , 16, buf, sizeof(buf), &olen);
    mbedtls_printf("E: %s\n", buf);

    mbedtls_mpi_write_string(&ctx->D , 16, buf, sizeof(buf), &olen);
    mbedtls_printf("D: %s\n", buf);

    mbedtls_mpi_write_string(&ctx->P , 16, buf, sizeof(buf), &olen);
    mbedtls_printf("P: %s\n", buf);

    mbedtls_mpi_write_string(&ctx->Q , 16, buf, sizeof(buf), &olen);
    mbedtls_printf("Q: %s\n", buf);

    mbedtls_mpi_write_string(&ctx->DP, 16, buf, sizeof(buf), &olen);
    mbedtls_printf("DP: %s\n", buf);

    mbedtls_mpi_write_string(&ctx->DQ, 16, buf, sizeof(buf), &olen);
    mbedtls_printf("DQ: %s\n", buf);

    mbedtls_mpi_write_string(&ctx->QP, 16, buf, sizeof(buf), &olen);
    mbedtls_printf("QP: %s\n", buf);
    mbedtls_printf("\n  +++++++++++++++++ rsa keypair +++++++++++++++++\n\n");
}

int main(void)
{
    int ret;
    size_t olen = 0;
    uint8_t out[2048/8];

    mbedtls_platform_set_printf(printf);
    mbedtls_platform_set_snprintf(snprintf);

    mbedtls_rsa_context ctx;
    mbedtls_entropy_context entropy;
    mbedtls_ctr_drbg_context ctr_drbg;
    const char *pers = "simple_rsa";
    const char *msg = "Hello, World!";

    mbedtls_entropy_init(&entropy);
    mbedtls_ctr_drbg_init(&ctr_drbg);
    mbedtls_rsa_init(&ctx, MBEDTLS_RSA_PKCS_V21, MBEDTLS_MD_SHA256);

    mbedtls_entropy_add_source(&entropy, entropy_source, NULL,
                               MBEDTLS_ENTROPY_MAX_GATHER,
                               MBEDTLS_ENTROPY_SOURCE_STRONG);
    ret = mbedtls_ctr_drbg_seed(&ctr_drbg, mbedtls_entropy_func, &entropy,
                                    (const uint8_t *) pers, strlen(pers));
    assert_exit(ret == 0, ret);
    mbedtls_printf("\n  . setup rng ... ok\n");

    mbedtls_printf("\n  ! RSA Generating large primes may take minutes! \n");
    ret = mbedtls_rsa_gen_key(&ctx, mbedtls_ctr_drbg_random,
                                        &ctr_drbg, 2048, 65537);
    assert_exit(ret == 0, ret);
    mbedtls_printf("\n  1. RSA generate key ... ok\n");
    dump_rsa_key(&ctx);

    ret = mbedtls_rsa_pkcs1_encrypt(&ctx, mbedtls_ctr_drbg_random,
                            &ctr_drbg, MBEDTLS_RSA_PUBLIC, strlen(msg), msg, out);
    assert_exit(ret == 0, ret);
    dump_buf("\n  2. RSA encryption ... ok", out, sizeof(out));

    ret = mbedtls_rsa_pkcs1_decrypt(&ctx, mbedtls_ctr_drbg_random, &ctr_drbg,
                                MBEDTLS_RSA_PRIVATE, &olen, out, out, sizeof(out));
    assert_exit(ret == 0, ret);

    out[olen] = 0;
    mbedtls_printf("\n  3. RSA decryption ... ok\n     %s\n", out);

    ret = memcmp(out, msg, olen);
    assert_exit(ret == 0, ret);
    mbedtls_printf("\n  4. RSA Compare results and plaintext ... ok\n");

cleanup:
    mbedtls_ctr_drbg_free(&ctr_drbg);
    mbedtls_entropy_free(&entropy);
    mbedtls_rsa_free(&ctx);

    return ret;
}
```

用例输出：

```
  . setup rng ... ok

  ! RSA Generating large primes may take minutes!

  1. RSA generate key ... ok

  +++++++++++++++++ rsa keypair +++++++++++++++++

N: E0E9960BF595B5F6C6251A3955CAC95F7CCC79F6060DBABFEEA94932E788A21A0B4755AFDDABBC50903FB916EC1FAB1EFB6724255C473B8558FFF6F14616B160148394
E: 010001
D: 10B7B6C6CE205755851B93916E1BBEA571AF4E8EC79B145083E58D62A7EC735ACAE5288203FB69E9F5C43C211A0D588E3053005023F074DA253D66C0E9B1721F197C9A
P: F1A53CF28982032D7D4551E28693E7A7F9D3B85ACD09264050F32C40E2C71E1520F0AC7E99E2BD7EF5611AE6E5B4A422BBD8B1E754A35158D4F9B5E71116277BA7E138
Q: EE45E28D15C7BD25FA5A40E5B3DD39BC2E6DBD205289B1A004A49D0F10221A49904A24C63C8036B47CF677AEBD9BF00BD84C5FC260C0466931B70559104D918F09D8ED
DP: D5EEC95F9C57CB4269A686513B7E1458857868BD92CAA7DFC70B12C1BB4437A0D311E055111E494FEE23F3323A694BEB284D376BAB660FADCA97ECF04E13440F58D8A
DQ: 87AA8CE2EDEACB5CCB5E062383B4CB81C521C0949DCA3EB3B0D11588151485C92AF9BC548EF025B5C08D08FA1A85A638E8501C19EDC2AC948AB4FDBB8757D33011588
QP: 939337884A81F91CBBEBE84A5B68190FB4FD0F9075F4B43C148328FB63FA67F1C5625722131277F95842CB14BA50E107EAE1125B72BA38C005AC3E5F46C86F0D1D3D5

  +++++++++++++++++ rsa keypair +++++++++++++++++


  2. RSA encryption ... ok
     4B 93 F9 3A 6E E7 73 52 19 00 51 FD FD A7 B3 10
     1E 56 65 BD EB 3A 7F F0 B7 1E E2 81 5B C6 C5 D8
     61 44 89 DF B7 A3 D4 E2 A9 FA 5B C4 58 20 E1 C6
     11 96 0C F2 55 12 72 C5 F6 CC D8 FB 52 0D 69 58
     61 7B 03 48 01 E9 38 CB EA 97 19 DA EA A7 C9 3A
     60 07 C7 26 A6 5C 4F 19 2D 21 DF A5 35 11 50 FC
     6E 18 B2 AB 94 58 BB FF 79 11 79 EC 66 FA C0 8E
     36 BE 56 6A E3 71 BE E0 4C 57 CB 77 3D DC 73 77
     26 B4 B6 0F F8 94 80 BB A4 02 95 04 0A 47 41 89
     7C 4A 4E E6 CF 9A A1 66 63 4A 5B FE 8E 3F 1F CC
     88 D5 48 DE F2 2C 06 34 73 A3 1A AF 10 63 A5 98
     CE 2A E6 7D A3 D3 F2 C7 F3 54 6B 3E CE F7 25 AB
     CF 2F D9 03 91 3C 04 70 C1 3F B9 9A EA 84 65 9A
     99 31 3C C4 A5 E9 8E 7D AD B3 D0 7D 6C 01 74 6B
     58 6F 58 52 25 A7 AA 33 0B 93 1A FF 3C 09 42 1F
     AC ED 8F 83 8E FA 0F 07 55 6F 54 BB 5E 77 A9 BB

  3. RSA decryption ... ok
     Hello, World!

  4. RSA Compare results and plaintext ... ok
```

#### **2.5 sha1**

```c

int get_sign_sha1(char *input, char *output)
{
    mbedtls_sha1_context sha1_ctx;
    mbedtls_sha1_init(&sha1_ctx);
    mbedtls_sha1_starts(&sha1_ctx);
    mbedtls_sha1_update(&sha1_ctx, (const unsigned char *)input, strlen(input));
    mbedtls_sha1_finish(&sha1_ctx, output);
}
```
