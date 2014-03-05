#########################################
#
#     PROCESAMIENTO DE DATOS
#
#########################################


# Guardo cada linea del input en el array 'mesas_raw'

mesas_raw = IO.readlines(Dir.pwd + "/mesas_dip.tsv")

# Elimino la primer linea del archivo, que contiene los titulos de las columnas:
#
#   seccion, circuito, mesa, blancos, AyL, FpV, UNEN, PRO, FIT, CP

mesas_raw.shift()

# Formateo cada mesa para transformarla en un array de numeros enteros y las guardo en mesas_completas.

def emprolijar(array_raw)
  array_prolijo = []
  for line in array_raw
    # quito el \n del final de la linea, la corto sobre los tabs y transformo a enteros el array resultante
    array_prolijo << line.chomp.split("\t").map { |x| x.to_i}
  end
  return array_prolijo
end

mesas_completas = emprolijar(mesas_raw)

# Separo el array con todos los datos en dos:
#     
#     data_mesas, con la info de cada mesa (seccion, circuito, numero de mesa)
#     votos_mesas, con los votos en cada mesa
#
#     data_mesas = [seccion, circuito, mesa]
#     votos_mesas = [blancos, AyL, FpV, UNEN, PRO, FIT, CP] (CP: Camino Popular)


data_mesas = mesas_completas.map(&:dup)
data_mesas.each {|mesa| mesa.pop(7)}

votos_mesas = mesas_completas.map(&:dup)
votos_mesas.each {|mesa| mesa.shift(3)}

# Si se quiere realizar el analisis CON VOTOS EN BLANCO, descomentar la proxima linea:
votos_mesas.each {|mesa| mesa.pop(1)}

#######################################
#
#     SIMULACIONES
#
#######################################

# Creo un array 'pesos', donde se guardan la cantidad de votos validos por mesa
pesos = votos_mesas.map { |x| x.reduce(:+) }

def samplear_por_mesa(mesa)
  voto = 0
  n = mesa.reduce(:+)
  sorteo = rand(1..n)
  while sorteo > mesa.first(voto+1).reduce(:+)
#    puts "El sorteo dio #{sorteo} y al partido #{voto} lo votaron #{mesa[voto]} personas."
    voto +=1
  end
  return voto
end


def sampleo_general(mesas)
  sampleo = []
  mesas.each_with_index do |mesa, i|
    samp = samplear_por_mesa(mesa)
#    puts "La mesa #{i} sampleo #{samp}. Woohoo!"
    sampleo << samp
  end
  puts
  return sampleo
end

#p votos_mesas
#gets
a = []
1.times do
  a << sampleo_general(votos_mesas)
  p a.length
end



#p sampleo_general([[1,2,120],[234,2,3],[5,456,4]])

#p votos_mesas[516]

b = Hash.new(0)
a.each do |v|
  b[v] += 1
end

puts b

