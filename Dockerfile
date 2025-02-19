FROM python:3 as build

WORKDIR /app/lib
COPY lib .
RUN apt update && apt install -y libjbig2dec0-dev \
    && cc -Wall -fPIC --shared -o libjbigdec.so jbigdec.cc JBigDecode.cc \
    && cc -Wall `pkg-config --cflags jbig2dec` -fPIC -shared -o libjbig2codec.so decode_jbig2data_x.cc `pkg-config --libs jbig2dec`

FROM python:3-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

RUN apt update && apt install -y mupdf-tools

COPY . .
COPY --from=build /app/lib/*.so .
CMD [ "python", "./caj2pdf" ]