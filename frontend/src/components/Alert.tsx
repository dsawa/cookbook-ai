import { ReactNode } from "react";

interface AlertProps {
  children: ReactNode;
}

export const Alert = ({ children }: AlertProps) => {
  return (
    <div className="alert alert-danger" role="alert">
      {children}
    </div>
  );
};
