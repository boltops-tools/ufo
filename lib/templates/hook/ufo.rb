# Docs: https://ufoships.com/docs/config/hooks/ufo/

before("ship",
  execute: "echo 'ufo before ship hook'",
)

after("ship",
  execute: "echo 'ufo after ship hook'",
)
