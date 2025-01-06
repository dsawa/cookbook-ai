interface ButtonProps {
  onClick?: (event: React.MouseEvent<HTMLButtonElement>) => void;
  disabled?: boolean;
  children: React.ReactNode;
}

export const Button = ({ onClick, disabled, children }: ButtonProps) => {
  return (
    <button disabled={disabled} onClick={onClick} className="btn btn-primary">
      {children}
    </button>
  );
};
