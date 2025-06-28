import React from 'react';

interface PersonalityWindowProps {
  type: 'SABLE' | 'NULL' | 'HONEY';
}

export const PersonalityWindow: React.FC<PersonalityWindowProps> = ({ type }) => {
  return (
    <div className="personality-window">
      <div className="personality-header">
        <h2>{type}.exe</h2>
      </div>
      <div className="personality-content">
        <p>Personality: {type}</p>
        <p>Status: Active</p>
        <p>Trust Level: 50%</p>
        <p>Corruption: 25%</p>
      </div>
    </div>
  );
}; 