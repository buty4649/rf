#include <winsock2.h>
#include <ws2tcpip.h>

#ifndef UNICODE
char* gai_strerrorA(int errcode)
{
    static char buf[GAI_STRERROR_BUFFER_SIZE + 1];

    FormatMessageA(
        FORMAT_MESSAGE_FROM_SYSTEM
            | FORMAT_MESSAGE_IGNORE_INSERTS
            | FORMAT_MESSAGE_MAX_WIDTH_MASK,
        NULL,
        errcode,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        buf, GAI_STRERROR_BUFFER_SIZE + 1,
        NULL);

    return buf;
}

#else

WCHAR* gai_strerrorW(int errcode)
{
    static WCHAR buf[GAI_STRERROR_BUFFER_SIZE + 1];

    FormatMessageW(
        FORMAT_MESSAGE_FROM_SYSTEM
            | FORMAT_MESSAGE_IGNORE_INSERTS
            | FORMAT_MESSAGE_MAX_WIDTH_MASK,
        NULL,
        errcode,
        MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
        buf, GAI_STRERROR_BUFFER_SIZE + 1,
        NULL);

    return buf;
}

#endif
