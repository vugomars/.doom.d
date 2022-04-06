# -*- mode: snippet -*-
# name: index.js
# key: index.js
# --
import '@commons/session'
import compat from '@commons/compat'
import error from '@commons/error'
import env from '@commons/globals/env'
import redis from './redis'
import mock from '@mock/mock'

const load = () => {
  error.listen()
  redis.run()
  compat.autoFocus('$1')
}

env.isDev(() => mock(load), load)