shader_type canvas_item;

// Parâmetros que você pode ajustar direto no Inspetor do Godot
uniform float star_density : hint_range(50.0, 500.0) = 200.0;
uniform float twinkle_speed : hint_range(0.1, 10.0) = 3.0;

// Função matemática para gerar números "aleatórios" baseados na posição
float random(vec2 uv) {
    return fract(sin(dot(uv.xy, vec2(12.9898,78.233))) * 43758.5453123);
}

void fragment() {
    // Quadricula a tela com base na densidade desejada
    vec2 grid_uv = floor(UV * star_density);

    // Gera um valor aleatório de 0.0 a 1.0 para cada quadradinho
    float star_value = random(grid_uv);

    // Só desenha a estrela se o valor aleatório for muito alto (ex: 98% de chance de ser espaço vazio)
    if (star_value > 0.98) {
        // Usa o tempo (TIME) e a posição para criar um brilho pulsante diferente para cada estrela
        float twinkle = (sin(TIME * twinkle_speed + random(grid_uv) * 10.0) + 1.0) / 2.0;
        
        // Define a cor da estrela (Branco) e o Alpha baseado na pulsação
        COLOR = vec4(1.0, 1.0, 1.0, twinkle);
    } else {
        // Fundo transparente para poder ver outras coisas atrás
        COLOR = vec4(0.0, 0.0, 0.0, 0.0); 
    }
}