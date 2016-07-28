data:extend({
	  {
		type = "explosion",
		name = "ntc-cannot-build",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__NoTurretCreep__/graphics/null.png",
				priority = "low",
				width = 32,
				height = 32,
				frame_count = 1,
				line_length = 1,
				animation_speed = 1
			},
		},
		light = {intensity = 0, size = 0},
		sound =
		{
		  {
			filename = "__NoTurretCreep__/sounds/cannot-build.ogg",
			volume = 0.99
		  },
		},
	  }

})
