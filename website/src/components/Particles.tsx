'use client';
import { useEffect, useRef } from 'react';
import { Renderer, Camera, Geometry, Program, Mesh } from 'ogl';

const vertex = /* glsl */`
  attribute vec3 position;
  attribute vec4 random;
  attribute vec3 color;
  uniform mat4 modelMatrix;
  uniform mat4 viewMatrix;
  uniform mat4 projectionMatrix;
  uniform float uTime;
  uniform float uSpread;
  uniform float uBaseSize;
  uniform float uSizeRandomness;
  varying vec4 vRandom;
  varying vec3 vColor;
  void main(){
    vRandom=random; vColor=color;
    vec3 pos=position*uSpread; pos.z*=10.0;
    vec4 mPos=modelMatrix*vec4(pos,1.0);
    float t=uTime;
    mPos.x+=sin(t*random.z+6.28*random.w)*mix(0.1,1.5,random.x);
    mPos.y+=sin(t*random.y+6.28*random.x)*mix(0.1,1.5,random.w);
    mPos.z+=sin(t*random.w+6.28*random.y)*mix(0.1,1.5,random.z);
    vec4 mvPos=viewMatrix*mPos;
    gl_PointSize=uSizeRandomness==0.0?uBaseSize:(uBaseSize*(1.0+uSizeRandomness*(random.x-0.5)))/length(mvPos.xyz);
    gl_Position=projectionMatrix*mvPos;
  }
`;

const fragment = /* glsl */`
  precision highp float;
  uniform float uTime;
  uniform float uAlphaParticles;
  varying vec4 vRandom;
  varying vec3 vColor;
  void main(){
    vec2 uv=gl_PointCoord.xy;
    float d=length(uv-vec2(0.5));
    if(uAlphaParticles<0.5){
      if(d>0.5)discard;
      gl_FragColor=vec4(vColor+0.2*sin(uv.yxx+uTime+vRandom.y*6.28),1.0);
    }else{
      float circle=smoothstep(0.5,0.4,d)*0.8;
      gl_FragColor=vec4(vColor+0.2*sin(uv.yxx+uTime+vRandom.y*6.28),circle);
    }
  }
`;

const hexToRgb = (hex: string): [number, number, number] => {
  hex = hex.replace(/^#/, '');
  if (hex.length === 3) hex = hex.split('').map(c => c + c).join('');
  const int = parseInt(hex, 16);
  return [((int >> 16) & 255) / 255, ((int >> 8) & 255) / 255, (int & 255) / 255];
};

interface ParticlesProps {
  particleCount?: number;
  particleSpread?: number;
  speed?: number;
  particleColors?: string[];
  alphaParticles?: boolean;
  particleBaseSize?: number;
  sizeRandomness?: number;
  cameraDistance?: number;
  className?: string;
}

export default function Particles({
  particleCount = 150,
  particleSpread = 8,
  speed = 0.06,
  particleColors = ['#00d4ff', '#7B2FFF', '#22c55e', '#ffffff'],
  alphaParticles = true,
  particleBaseSize = 80,
  sizeRandomness = 1,
  cameraDistance = 20,
  className = '',
}: ParticlesProps) {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const container = containerRef.current;
    if (!container) return;

    const renderer = new Renderer({ dpr: Math.min(window.devicePixelRatio, 2), depth: false, alpha: true });
    const gl = renderer.gl;
    container.appendChild(gl.canvas);
    gl.clearColor(0, 0, 0, 0);

    const camera = new Camera(gl, { fov: 15 });
    camera.position.set(0, 0, cameraDistance);

    const resize = () => {
      renderer.setSize(container.clientWidth, container.clientHeight);
      camera.perspective({ aspect: gl.canvas.width / gl.canvas.height });
    };
    window.addEventListener('resize', resize);
    resize();

    const count = particleCount;
    const positions = new Float32Array(count * 3);
    const randoms = new Float32Array(count * 4);
    const colors = new Float32Array(count * 3);

    for (let i = 0; i < count; i++) {
      let x: number, y: number, z: number, len: number;
      do {
        x = Math.random() * 2 - 1; y = Math.random() * 2 - 1; z = Math.random() * 2 - 1;
        len = x * x + y * y + z * z;
      } while (len > 1 || len === 0);
      const r = Math.cbrt(Math.random());
      positions.set([x * r, y * r, z * r], i * 3);
      randoms.set([Math.random(), Math.random(), Math.random(), Math.random()], i * 4);
      colors.set(hexToRgb(particleColors[Math.floor(Math.random() * particleColors.length)]), i * 3);
    }

    const geometry = new Geometry(gl, {
      position: { size: 3, data: positions },
      random: { size: 4, data: randoms },
      color: { size: 3, data: colors },
    });

    const program = new Program(gl, {
      vertex, fragment,
      uniforms: {
        uTime: { value: 0 },
        uSpread: { value: particleSpread },
        uBaseSize: { value: particleBaseSize * Math.min(window.devicePixelRatio, 2) },
        uSizeRandomness: { value: sizeRandomness },
        uAlphaParticles: { value: alphaParticles ? 1 : 0 },
      },
      transparent: true, depthTest: false,
    });

    const mesh = new Mesh(gl, { mode: gl.POINTS, geometry, program });
    let rafId: number;
    let lastTime = performance.now();
    let elapsed = 0;

    const update = (t: number) => {
      rafId = requestAnimationFrame(update);
      elapsed += (t - lastTime) * speed;
      lastTime = t;
      program.uniforms.uTime.value = elapsed * 0.001;
      mesh.rotation.x = Math.sin(elapsed * 0.0002) * 0.1;
      mesh.rotation.y = Math.cos(elapsed * 0.0005) * 0.15;
      mesh.rotation.z += 0.003 * speed;
      renderer.render({ scene: mesh, camera });
    };
    rafId = requestAnimationFrame(update);

    return () => {
      cancelAnimationFrame(rafId);
      window.removeEventListener('resize', resize);
      if (container.contains(gl.canvas)) container.removeChild(gl.canvas);
    };
  }, []);

  return (
    <div ref={containerRef} className={`w-full h-full ${className}`} style={{ position: 'absolute', inset: 0 }} />
  );
}
