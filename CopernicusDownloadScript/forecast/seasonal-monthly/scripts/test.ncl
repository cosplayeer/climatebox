lat = new((/2,3/),"float")
i = 0
do while (i .lt. 2)
  j = 0
  do while (j .lt. 3)
  lat(i,j) = 3
  j = j + 1
  end do
i = i + 1
end do
print(lat)