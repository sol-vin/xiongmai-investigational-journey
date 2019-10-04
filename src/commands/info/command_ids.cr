module Command::Ids
  ALL = {
    config_set: {
      request:  0x0410,
      response: 0x0411,
    },

    config_get: {
      request:  0x0412,
      response: 0x0413,
    },

    default_config_get: {
      request:  0x0414,
      response: 0x0415,
    },

    config_channel_title_set: {
      request:  0x0416,
      response: 0x0417,
    },

    config_channel_title_get: {
      request:  0x0418,
      response: 0x0419,
    },

    config_channel_title_dot_set: {
      request:  0x041A,
      response: 0x041B,
    },

    system_debug: {
      request:  0x041C,
      response: 0x041D,
    },

    ability_get: {
      request:  0x0550,
      response: 0x0551,
    },

    ptz: {
      request:  0x0578,
      response: 0x0579,
    },

    monitor: {
      request:  0x0582,
      response: 0x0583,
      data:     0x0584,
      claim_rq: 0x0585,
      claim_rs: 0x0586,
    },

    play: {
      request:  0x058C,
      response: 0x058D,
      data:     0x058E,
      eof:      0x058F,
      claim_rq: 0x0590,
      claim_rs: 0x0591,
      downdata: 0x0592,
    },

    talk: {
      request:  0x0596,
      response: 0x0597,
      cli_data: 0x0598,
      cam_data: 0x0599,
      claim_rq: 0x059A,
      claim_rs: 0x059B,
    },

    file_search: {
      request:  0x05A0,
      response: 0x05A1,
      time_req: 0x05A4,
      time_rs:  0x05A5,
    },

    log_search: {
      request:  0x05A2,
      response: 0x05A3,
    },

    system_manager: {
      request:  0x05AA,
      response: 0x05AB,
    },

    time_query: {
      request:  0x05AC,
      response: 0x05AD,
    },

    disk_manager:  {
      request:  0x05B4,
      response: 0x05B5,
    },

    authority_list_get:  {
      request:  0x05BE,
      response: 0x05BF,
    },

    users_get: {
      request:  0x05C0,
      response: 0x05C1,
    },

    groups_get: {
      request:  0x05C2,
      response: 0x05C3,
    },

    add_group: {
      request:  0x05C4,
      response: 0x05C5,
    },

    modify_group: {
      request:  0x05C6,
      response: 0x05C7,
    },

    delete_group: {
      request:  0x05C8,
      response: 0x05C9,
    },

    add_user: {
      request:  0x05CA,
      response: 0x05CB,
    },

    modify_user: {
      request:  0x05CC,
      response: 0x05CD,
    },

    delete_user: {
      request:  0x05CE,
      response: 0x05CF,
    },

    modify_password: {
      request:  0x05D0,
      response: 0x05D1,
    },

    guard: {
      request:  0x05DC,
      response: 0x05DD,
    },

    unguard: {
      request:  0x05DE,
      response: 0x05DF,
    },

    alarm: {
      request:  0x05E0,
      response: 0x05E1,
    },

    net_alarm: {
      request:  0x05E2,
      response: 0x05E3,
      msg_rq:   0x05E4,
    },

    upgrade: {
      request:  0x05F0,
      response: 0x05F1,
      data_rq:  0x05F2,
      data_rs:  0x05F3,
      prog:     0x05F4,
      info_rq:  0x05F5,
      info_rs:  0x05F6,
    },

    ip_search: {
      request:  0x05FA,
      response: 0x05FB,
    },

    ip_set: {
      request:  0x05FC,
      response: 0x05FD,
    },

    config_import: {
      request:  0x0604,
      response: 0x0605,
    },

    config_export: {
      request:  0x0606,
      response: 0x0607,
    },

    log_export: {
      request:  0x0608,
      response: 0x0609,
    },

    net_keyboard: {
      request:  0x060E,
      response: 0x060F,
    },
    
    net_snap: {
      request:  0x0618,
      response: 0x0619,
      set_rq:   0x061A,
      set_rs:   0x061B,
    },

    rs232: {
      read_rq:  0x0622,
      read_rs:  0x0623,
      write_rq: 0x0624,
      write_rs: 0x0625,
    },

    rs485: {
      read_rq:  0x0626,
      read_rs:  0x0627,
      write_rq: 0x0628,
      write_rs: 0x0629,
    },

    transparent_comm: {
      request:  0x062A,
      response: 0x062B,
      rs485_rq: 0x062C,
      rs485_rs: 0x062D,
      rs232_rq: 0x062E,
      rs232_rs: 0x062F,
    },

    sync_time: {
      request:  0x0636,
      response: 0x0637,
    },

    photo_get: {
      request:  0x0640,
      response: 0x0641,
    },
  }
end