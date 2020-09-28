FROM python:3.8 AS build-image

RUN curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python

ARG VERSION

COPY . /app
WORKDIR /app

RUN $HOME/.poetry/bin/poetry version $VERSION && \
    $HOME/.poetry/bin/poetry build && \
    $HOME/.poetry/bin/poetry export -f requirements.txt -o dist/requirements.txt

FROM python:3.8
COPY --from=build-image /app/dist/requirements.txt /tmp
RUN pip install -r /tmp/requirements.txt

COPY --from=build-image /app/dist/*.whl /tmp
RUN pip install /tmp/*.whl

USER 1000

VOLUME ["/repo"]
WORKDIR /repo

ENTRYPOINT ["secrets_tool"]
CMD ["decrypt"]
