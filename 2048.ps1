
function Center-Text {
	param(
		[string]$text,
		[int]$length
	)

	if ($text.Length -ge $length) {
		return $text
	}

	$spaces = $length - $text.Length
	$left = [math]::Floor($spaces / 2)
	$right = $spaces - $left

	return (' ' * $right) + $text + (' ' * $left)
}

$colorMap = @(
	@('DarkGray', 'White'),
	@('Red', 'White'),
	@('Green', 'Black'),
	@('Blue', 'White'),
	@('Yellow', 'Black'),
	@('Magenta', 'White'),
	@('Cyan', 'Black'),
	@('Black', 'White'),
	@('Gray', 'Black'),
	@('DarkRed', 'White'),
	@('DarkGreen', 'Black'),
	@('DarkBlue', 'Black'),
	@('DarkYellow', 'Black'),
	@('DarkMagenta', 'White'),
	@('DarkCyan', 'Black')
)


# for ($i = 0; $i -lt 30; $i++) {
# 	$txt = Center-Text $i 20
# 	$clr = $colorMap[$i % $colorMap.Count]
# 	Write-Host "$txt" -ForegroundColor $clr[1] -BackgroundColor $clr[0] -NoNewLine
# 	Write-Host ' '
# }

$field = @(
	@(0, 0, 0, 0),
	@(0, 0, 0, 0),
	@(0, 0, 0, 0),
	@(0, 0, 0, 0)
)



function Print-Row {
	param (
		[int]$index
	)
	
	for ($i = 0; $i -lt 3; $i++) {
		for ($j = 0; $j -lt 4; $j++) {
			$color = $colorMap[$field[$index][$j] % $colorMap.Count]

			if ($i -eq 1) {
				$n = $field[$index][$j]
				if ($n -eq 0) {
					$n = "."
				} else {
					$n = 1 -shl $n
				}
				$formatted = Center-Text $n 6
				Write-Host "$formatted" -ForegroundColor $color[1] -BackgroundColor $color[0] -NoNewLine
			} else {
				Write-Host (' ' * 6) -ForegroundColor $color[1] -BackgroundColor $color[0] -NoNewLine
			}
		}
		Write-Host ' '
	}
}

function Prepare-Window {
	for ($i = 0; $i -lt 12; $i++) {
		Write-Host ''
	}
}

function Go-Up {
	$y = [Console]::CursorTop
	[Console]::SetCursorPosition(0, ($y - 12))
}

function Print-Field {
	[Console]::CursorVisible = $false
	for ($i = 0; $i -lt 4; $i++) {
		Print-Row $i
	}
	[Console]::CursorVisible = $true
}

function Swap-Elements {
	param (
		[int]$x,
		[int]$y,
		[int]$z,
		[int]$t
	)
	$field[$x][$y] = $field[$x][$y] + $field[$z][$t]
	$field[$z][$t] = $field[$x][$y] - $field[$z][$t]
	$field[$x][$y] -= $field[$z][$t]
}

function Rotate-Field {
	param (
		[int]$angle
	)

	if ($angle -eq 0) {
		# no action
		return
	}
	if ($angle -lt 0) {
		$angle += 4
	}

	switch ($angle) {
		1 {
			for ($i = 0; $i -lt 4; $i++) {
				for ($j = $i + 1; $j -lt 4; $j++) {
					Swap-Elements $i $j $j $i
				}
			}
			for ($i = 0; $i -lt 4; $i++) {
				for ($j = 0; $j -lt 2; $j++) {
					Swap-Elements $i $j $i (3 - $j)
				}
			}
		}
		2 {
			for ($i = 0; $i -lt 2; $i++) {
				for ($j = 0; $j -lt 4; $j++) {
					Swap-Elements $i $j (3 - $i) (3 -$j)
				}
			}
		}
		3 {
			for ($i = 0; $i -lt 4; $i++) {
				for ($j = $i + 1; $j -lt 4; $j++) {
					Swap-Elements $i $j $j $i
				}
			}
			for ($i = 0; $i -lt 2; $i++) {
				for ($j = 0; $j -lt 4; $j++) {
					Swap-Elements $i $j (3 - $i) $j
				}
			}
		}
	}
}

function Compress-Field {
	for ($i = 0; $i -lt 4; $i++) {
		for ($j = 3; $j -gt -1; $j--) {
			if ($field[$i][$j] -eq 0) {
				# find first non-zero element
				for ($k = $j - 1; $k -gt -1; $k--) {
					if ($field[$i][$k] -ne 0) {
						Swap-Elements $i $j $i $k
						break
					}
				}
			}
		}
	}
}

function Process-Field {
	for ($i = 0; $i -lt 4; $i++) {
			for ($j = 3; $j -gt 0; $j--) {
				if ($field[$i][$j] -ne 0) {
					if ($field[$i][$j] -eq $field[$i][($j - 1)]) {
						$field[$i][$j] += 1
						$field[$i][($j - 1)] = 0
					}
				}
			}
		}
}

$zeroes = @()

function Find-Zeroes {
	$global:zeroes = @()
	for ($i = 0; $i -lt 4; $i++) {
		for ($j = 0; $j -lt 4; $j++) {
			if ($field[$i][$j] -eq 0) {
				$global:zeroes += ,@($i, $j)
			}
		}
	}
}

function Add-Elem {
	Find-Zeroes
	if ($zeroes.Count -eq 0) {
		return $false
	}
	if ($zeroes.Count -eq 1) {
		$ind = $zeroes[0]
	} else {
		$ind = Get-Random -InputObject $zeroes
	}
	$elem = 1
	$choice = Get-Random -Minimum 0 -Maximum 3
	if ($choice -eq 0) {
		$elem = 2
	}
	$field[$ind[0]][$ind[1]] = $elem
	return $true
}

function Make-Step {
	param (
		[int]$direction
	)
	Rotate-Field $direction
	Compress-Field
	Process-Field
	Compress-Field
	Rotate-Field ($direction * -1)
	return Add-Elem
}


function Run-MainLoop {
	$w = [Console]::WindowWidth
	$h = [Console]::WindowHeight
	if ($w -lt 30 || $h -lt 15) {
		Write-Host "Your console is too small for this game."
		return
	}
	Write-Host "Arrow keys to move, q to quit"
	$ok = Add-Elem
	$ok = Add-Elem
	Prepare-Window
	while ($true) {
		Go-Up
		Print-Field
		$ok = $true
		$key = $Host.UI.RawUI.ReadKey("IncludeKeyDown,NoEcho")
		switch ($key.VirtualKeyCode) {
			37 {
				# left
				$ok = Make-Step 2
			}
			38 {
				# up
				$ok = Make-Step 1
			}
			39 {
				# right
				$ok = Make-Step 0
			}
			40 {
				# down
				$ok = Make-Step 3
			}
			81 {
				# q
				return
			}
			113 {
				# Q
				return
			}
			
		}
		if (!$ok) {
			Write-Host "`a"
			Write-Host "Game Over!"
			return
		}
	}
}

Run-MainLoop
