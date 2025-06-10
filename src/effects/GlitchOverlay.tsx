import React, { useEffect, useRef } from 'react';

interface GlitchOverlayProps {
  intensity: number;
}

export const GlitchOverlay: React.FC<GlitchOverlayProps> = ({ intensity }) => {
  const canvasRef = useRef<HTMLCanvasElement>(null);

  useEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) return;

    const ctx = canvas.getContext('2d');
    if (!ctx) return;

    // 🎨 Set canvas size
    const resizeCanvas = () => {
      canvas.width = window.innerWidth;
      canvas.height = window.innerHeight;
    };

    resizeCanvas();
    window.addEventListener('resize', resizeCanvas);

    // 🎭 Glitch effect animation
    let animationFrameId: number;
    const animate = () => {
      if (!ctx) return;

      // Clear canvas
      ctx.clearRect(0, 0, canvas.width, canvas.height);

      // Only apply glitch if intensity is high enough
      if (intensity > 0.1) {
        // 🎨 Draw glitch lines
        ctx.strokeStyle = `rgba(255, 0, 255, ${intensity * 0.3})`;
        ctx.lineWidth = 2;

        for (let i = 0; i < 10; i++) {
          const y = Math.random() * canvas.height;
          const width = Math.random() * canvas.width * 0.2;
          const x = Math.random() * canvas.width;

          ctx.beginPath();
          ctx.moveTo(x, y);
          ctx.lineTo(x + width, y);
          ctx.stroke();
        }

        // 🎨 Draw glitch blocks
        if (intensity > 0.5) {
          ctx.fillStyle = `rgba(0, 255, 255, ${intensity * 0.2})`;
          
          for (let i = 0; i < 5; i++) {
            const x = Math.random() * canvas.width;
            const y = Math.random() * canvas.height;
            const size = Math.random() * 50 * intensity;

            ctx.fillRect(x, y, size, size);
          }
        }

        // 🎨 Draw scan lines
        ctx.strokeStyle = `rgba(255, 255, 255, ${intensity * 0.1})`;
        ctx.lineWidth = 1;

        for (let y = 0; y < canvas.height; y += 2) {
          if (Math.random() > 0.95) {
            ctx.beginPath();
            ctx.moveTo(0, y);
            ctx.lineTo(canvas.width, y);
            ctx.stroke();
          }
        }
      }

      animationFrameId = requestAnimationFrame(animate);
    };

    animate();

    return () => {
      window.removeEventListener('resize', resizeCanvas);
      cancelAnimationFrame(animationFrameId);
    };
  }, [intensity]);

  return (
    <canvas
      ref={canvasRef}
      className="glitch-overlay"
      style={{
        position: 'fixed',
        top: 0,
        left: 0,
        pointerEvents: 'none',
        zIndex: 9999,
        mixBlendMode: 'screen'
      }}
    />
  );
}; 