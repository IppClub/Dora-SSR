import React, { useState, useRef, useEffect } from 'react';
import clsx from 'clsx';
import Link from '@docusaurus/Link';
import styles from './styles.module.css';

export interface DropdownItem {
  label: string;
  to: string;
  target?: '_blank' | '_self' | '_parent' | '_top';
}

export interface DropdownProps {
  label: string;
  items: DropdownItem[];
  className?: string;
}

export default function Dropdown({ label, items, className }: DropdownProps): React.ReactElement {
  const [isOpen, setIsOpen] = useState(false);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const handleMouseEnter = () => {
    setIsOpen(true);
  };

  const handleMouseLeave = () => {
    setIsOpen(false);
  };

  // Close dropdown when clicking outside
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsOpen(false);
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  return (
    <div
      className={clsx(styles.dropdown, className)}
      onMouseEnter={handleMouseEnter}
      onMouseLeave={handleMouseLeave}
      ref={dropdownRef}
    >
      <div className={styles.dropdownTrigger}>
        {label}
        <span className={styles.dropdownArrow}>▼</span>
      </div>
      {isOpen && (
        <div className={styles.dropdownMenu}>
          {items.map((item, index) => (
            <Link
              key={index}
              to={item.to}
              target={item.target}
              className={styles.dropdownItem}
              onClick={() => setIsOpen(false)}
            >
              {item.label}
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}